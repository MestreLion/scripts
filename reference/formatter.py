# This file is part of Scripts, see <https://github.com/MestreLion/scripts>
# Copyright (C) 2021 Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
# License: GPLv3 or later, at your choice. See <http://www.gnu.org/licenses/gpl>

"""
    Tests on string formatting and emulating logging.Logger.log() behaviour
"""

import collections
import logging
import string

log = logging.getLogger(__name__)


class Record:
    """Emulate logging.LogRecord to test Formatter. By design does not take keywords"""
    def __init__(self, msg, *args):
        self.msg = msg
        self.args = args

    def format(self, style='%'):
        return Formatter(style=style).format(self.msg, *self.args)

class Formatter:
    """Formats a message with positional and keyword arguments

    Formatting style may be selected out of %-format, str.format() or string.Template

    Perform some special argument handling:
    - Percent-format accept either positional OR keyword arguments (but not both)
      - If keywords, pack them and perform a dict formatting: msg % kwargs
      - If a mapping is the sole positional argument, use it: msg % args[0]
         (like logging does)
    - For str.format and string.Template, if no keywords and a mapping is the sole
        positional argument, unpack it and use as keywords: msg.format(*args, **args[0])
    """
    def _mux(msg, args, kwargs):  # @NoSelf
        if kwargs:
            if args:
                raise ValueError("Cannot percent-format both positional and keyword"
                                 " arguments: {!r}, {}, {}".format(msg, args, kwargs))
            args = kwargs
        elif (len(args) == 1 and isinstance(args[0], collections.Mapping)):
            args = args[0]
        return args, {}

    def _demux(_, args, kwargs):  # @NoSelf
        if not kwargs and len(args) == 1 and isinstance(args[0], collections.Mapping):
            kwargs = args[0]
        return args, kwargs

    _STYLES = {
        '%': (  _mux, lambda m, a, _:  m % a),
        '{': (_demux, lambda m, a, kw: m.format(*a, **kw)),
        '$': (_demux, lambda m, a, kw: string.Template(m).substitute(*a, **kw)),
    }
    def __init__(self, style='%'):
        if style not in self._STYLES:
            raise ValueError('Style must be one of: %s' % ','.join(self._STYLES.keys()))
        # func.__get__(self)  # convert func to bound method
        self._formatter = self._STYLES[style]

    def format(self, msg, *args, **kwargs):
        if self._formatter[0]:
            args, kwargs = self._formatter[0](str(msg), args, kwargs)
        return self._formatter[1](str(msg), args, kwargs)


if __name__ == '__main__':
    d = {'name':'rodrigo'}
    
    for style, msg in (
        ('%', "Hello, %r!"),
        ('%', "Hello, %(name)r!"),
        ('{', "Format {name!r}!"),
        ('$', "Template $name!"),
    ):
        print(Record(msg, d).format(style))
        if style == '%':
            log.error(msg, d)
            print(msg % d)
