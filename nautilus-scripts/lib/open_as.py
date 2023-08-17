# This file is part of Scripts, see <https://github.com/MestreLion/scripts>
# Copyright (C) 2023 Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
# License: GPLv3 or later, at your choice. See <http://www.gnu.org/licenses/gpl>

"""Open paths/uris using the default handler of a given mimetype"""

import sys
from gi.repository import Gio

if __name__ == "__main__":
    try:
        mime = sys.argv[1]
        uris = sys.argv[2:]
    except IndexError:
        sys.stderr.write("Missing MIMETYPE argument.\n"
                         f"Usage: {sys.argv[0]} MIMETYPE [PATH(s)...]\n")
        sys.exit(1)
    try:
        sys.exit(Gio.AppInfo.get_default_for_type(mime, True).launch_uris(uris, None))
    except AttributeError:
        sys.exit(f"No default application to open '{mime}'")
