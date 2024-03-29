# Enable custom ~/.python_history location on Python interactive console
# Set PYTHONSTARTUP to this file on ~/.profile or similar
# See https://github.com/MestreLion/scripts/tree/main/home/
#
# Copyright (C) 2023 Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
# License: GPLv3 or later, at your choice. See <http://www.gnu.org/licenses/gpl>
# ------------------------------------------------------------------------------

# References:
# https://docs.python.org/3/using/cmdline.html#envvar-PYTHONSTARTUP
# https://docs.python.org/3/library/readline.html#example
# https://github.com/python/cpython/blob/main/Lib/site.py @ enablerlcompleter()
# https://unix.stackexchange.com/a/704612/4919

import atexit
import os
import sys
import time
try:
    import readline
except ImportError:
    # Some systems (Dropbear) lack readline module
    readline = None

if sys.version_info[0] < 3:
    # noinspection PyShadowingBuiltins
    FileNotFoundError = IOError


# noinspection PyPep8Naming, MODE_ALL, MODE_OWNER
def write_history(path):
    import os
    import readline
    import sys
    # Py2/Py3 octal literals compatibility
    MODE_ALL   = 511  # 0777, 0o777
    MODE_OWNER = 448  # 0700, 0o700
    if sys.version_info[0] >= 3:
        makedirs = os.makedirs
    else:
        def makedirs(name, mode=MODE_ALL, exist_ok=False):
            try:
                os.makedirs(name, mode)
            except OSError as e:
                if e.errno != 17 or not exist_ok:
                    raise
    try:
        makedirs(os.path.dirname(path), mode=MODE_OWNER, exist_ok=True)
        readline.write_history_file(path)
    except OSError:
        pass


def register_atexit():
    # By default, ~/.local/state/python/{python2_,}history
    history = os.environ.get('PYTHONHISTORY') or (
        os.path.join(
            os.environ.get('XDG_STATE_HOME') or os.path.expanduser('~/.local/state'),
            '{}history'.format("" if sys.version_info[0] >= 3 else "python2_")
        )
    )
    try:
        readline.read_history_file(history)
    except FileNotFoundError:
        pass

    # Prevents creation of default history if custom is empty
    if readline.get_current_history_length() == 0:
        readline.add_history('# History created at {}'.format(time.asctime()))

    atexit.register(write_history, history)


if readline:
    register_atexit()

if sys.version_info[0] < 3:
    del FileNotFoundError
del (atexit, os, sys, time, readline, write_history, register_atexit)
