# Enable custom ~/.python_history location on Python interactive console
# Set PYTHONSTARTUP to this file on ~/.profile or similar
# See https://github.com/MestreLion/scripts/home/
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
import readline
import sys
import time


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
        def makedirs(name, mode=MODE_ALL , exist_ok=False):
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


# noinspection PyShadowingBuiltins
FileNotFoundError = IOError if sys.version_info[0] < 3 else FileNotFoundError

history = os.path.join(os.environ.get('XDG_CACHE_HOME') or
                       os.path.expanduser('~/.cache'),
                       'python{}_history'.format(sys.version_info[0]))
try:
    readline.read_history_file(history)
except FileNotFoundError:
    pass

# Prevents creation of default history if custom is empty
if readline.get_current_history_length() == 0:
    readline.add_history('# History created at {}'.format(time.asctime()))

atexit.register(write_history, history)

if sys.version_info[0] < 3:
    del FileNotFoundError
del (atexit, os, readline, sys, time, history, write_history)
