#!/usr/bin/env python3
#
# Listing Drives using UDisks
# https://github.com/storaged-project/udisks/issues/747
# http://storaged.org/doc/udisks2-api/latest/
# 2 approaches:
# - Call UDisks daemon directly via DBus calls
# - Use UDisks python bindings "wrapper" via PyGObject introspection

import sys
import typing as t

# Debian/Ubuntu: gir1.2-udisks-2.0
#    (and python3-gi, installed by default even in minimal headless servers)
try:
    import gi
    gi.require_version("UDisks", "2.0")
    from gi.repository import UDisks
except (ValueError, ImportError) as e:
    sys.exit(f"{e}, try:\n\tsudo apt install gir1.2-udisks-2.0")


# -----------------------------------------------------------------------------
# Direct DBus
# http://storaged.org/doc/udisks2-api/latest/ref-dbus.html
class UDisksDBus:
    import dbus  # dbus-python
    SERVICE = 'org.freedesktop.UDisks2'

    def __init__(self):
        self.bus = self.dbus.SystemBus()

    def status(self):
        """
        List all drives using a format similar to `udisksctl status`,
        sans header or sorting and using TABs as separators.
        """
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
    #path:   str = ""           # DBus path for object


def sort_key(storage: Storage) -> str:
    # Less general: storage.info.get_sort_key(), storage.drive.props.sort_key
    return storage.block.props.id


def status():
    """
    List all drives, properly sorted, using their one-liner description.
    """
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
        # For UDisks < 2.1 (2013), without ObjectInfo, deprecated in 2.1:
        if (UDisks.MAJOR_VERSION, UDisks.MINOR_VERSION) < (2, 1):
            "{0.out_name}\t{0.out_description}\t{0.out_drive_icon.props.names}".format(
                client.get_drive_info(storage.drive),  # gi._gi.ResultTuple
            )


def object_info():
    # W.I.P...
    client: UDisks.Client = UDisks.Client.new_sync()
    info: UDisks.ObjectInfo
    obj: UDisks.Object
    for obj in (client.get_object(_.get_object_path()) for _ in
                client.get_object_manager().get_objects()):
        drive: UDisks.Drive = obj.get_drive()  # or obj.props.drive
        d = dict()
        d.update()
        if drive is None:
            continue
        storage = Storage(
            object=obj,
            drive=drive,
            info=client.get_object_info(obj),  # new in UDisks 2.1
            block=client.get_block_for_drive(drive, get_physical=False),
        )


def device_description(device: str):
    """
    Minimal UDisks.ObjectInfo.get_one_liner() wrapper for a single device

    device: /dev/sda, /dev/sda1, /dev/loop1, /dev/loop1p2, ...
    """
    path = f"/org/freedesktop/UDisks2/block_devices/{device[5:]}"
    client: UDisks.Client = UDisks.Client.new_sync()
    obj: UDisks.Object = client.get_object(path)
    if obj is None:
        raise FileNotFoundError(f"Device not found: {device}")
    info: UDisks.ObjectInfo = client.get_object_info(obj)
    print(info.get_one_liner())


def example():
    # Another W.I.P. / Demo
    client = UDisks.Client.new_sync(None)
    manager = client.get_object_manager()
    objects = manager.get_objects()
    for o in objects:
        print('%s:' % o.get_object_path())
        ifaces = o.get_interfaces()
        for i in ifaces:
            print(' IFace %s' % i.get_interface_name())
        print('')


# -----------------------------------------------------------------------------
print("DBus:")
UDisksDBus().status()
print("\nLib:")
status()
# print("\nExample:")
# example()
#print("\nObjectInfo:")
#object_info()
print("Done!")

if len(sys.argv) > 1:
    print()
    try:
        device_description(sys.argv[1])
    except Exception as e:
        sys.exit(str(e))
