# Listing Drives using UDisks
# https://github.com/storaged-project/udisks/issues/747
# http://storaged.org/doc/udisks2-api/latest/
# 2 approaches:
# - Call UDisks daemon directly via DBus calls
# - Use UDisks python bindings "wrapper" via PyGObject introspection

import typing as t

import gi
gi.require_version("UDisks", "2.0")

from gi.repository import UDisks


# -----------------------------------------------------------------------------
# Direct DBus
# http://storaged.org/doc/udisks2-api/latest/ref-dbus.html
class UDisksDBus:
    import dbus  # dbus-python
    SERVICE = 'org.freedesktop.UDisks2'

    def __init__(self):
        self.bus = self.dbus.SystemBus()

    def status(self):
        udisks = self.bus.get_object(self.SERVICE, '/org/freedesktop/UDisks2')
        manager = udisks.GetManagedObjects(dbus_interface="org.freedesktop.DBus.ObjectManager",
                                           byte_arrays=True)
        objs = manager.items()
        # TODO: proper sorting using drive["SortKey"]
        for path, obj in sorted(objs):
            # alternative:
            # iface = dbus.Interface(udisks, "org.freedesktop.DBus.ObjectManager")
            # for path, obj in iface.GetManagedObjects().items():
            drive = obj.get("org.freedesktop.UDisks2.Drive", {})
            if not drive:
                continue
            blocks = self.drive_blocks(objs, path)
            devices = " ".join(self.to_str(block["Device"]).lstrip("/dev/") for block in blocks)
            self.print_drive(drive, devices)

    @staticmethod
    def to_str(array: bytes):
        return array.strip(b'\x00').decode()

    @staticmethod
    def print_drive(drive, devices):
        # Actually a bit more complex than that, see handle_command_status()
        # https://github.com/storaged-project/udisks/blob/master/tools/udisksctl.c#L2999
        print("%s\t%s" % (("%(Model)s\t%(Revision)s\t%(Serial)s\t%(Size)s" % drive), devices))

    @staticmethod
    def drive_blocks(objs, drive_path):
        for path, obj in objs:
            block = obj.get("org.freedesktop.UDisks2.Block", {})
            if not block or "org.freedesktop.UDisks2.Partition" in obj:
                continue
            if block["Drive"] == drive_path:
                yield block


# -----------------------------------------------------------------------------
# UDisks PyGObject introspection
# http://storaged.org/doc/udisks2-api/latest/ref-library.html
# https://lazka.github.io/pgi-docs/#UDisks-2.0
class Storage(t.NamedTuple):
    object: UDisks.Object      # superclass used to derive Drive and ObjectInfo
    drive:  UDisks.Drive       # individual properties (model, serial, size, etc)
    block:  UDisks.Block       # drive device (/dev/sdX)
    info:   UDisks.ObjectInfo  # general sort key and handy one-liner description


def sort_key(storage: Storage) -> str:
    return storage.info.get_sort_key()  # Less general: storage.drive.props.sort_key


def status():
    client: UDisks.Client = UDisks.Client.new_sync()
    obj: UDisks.Object
    drives: t.List[Storage] = []

    for obj in (client.get_object(_.get_object_path()) for _ in
                client.get_object_manager().get_objects()):
        drive: UDisks.Drive = obj.get_drive()  # or obj.props.drive
        if drive is None:
            continue
        storage = Storage(
            object=obj,
            drive=drive,
            info=client.get_object_info(obj),  # new in UDisks 2.1
            block=client.get_block_for_drive(drive, get_physical=False),
        )
        drives.append(storage)

    for storage in sorted(drives, key=lambda _: _.drive.props.sort_key):
        print(storage.info.get_one_liner())
        # Alternatives:
        # Drive/Block properties:
        "{0.model}\t{0.revision}\t{0.serial}\t{0.size}\t{1.device}".format(
            storage.drive.props,
            storage.block.props,
        )
        # For UDisks < 2.1 (no ObjectInfo)
        "{0.out_name}\t{0.out_description}\t{0.out_drive_icon.props.names}".format(
            client.get_drive_info(storage.drive),  # gi._gi.ResultTuple
        )


# -----------------------------------------------------------------------------
print("DBus:")
UDisksDBus().status()
print()
print("Lib:")
status()
