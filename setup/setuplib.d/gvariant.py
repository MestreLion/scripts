# Support for gvariant
# Uses list instead of set to preserve order
#
# Copyright (C) 2021 Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
# License: GPLv3 or later. See <http://www.gnu.org/licenses/gpl.html>

import ast
import sys

TYPES=('s', 'u')

class MyError(ValueError):
    pass


def main(op: str, itemtype: str, strlist: str, *items) -> 'Tuple[str, list]':
    if itemtype not in TYPES:
        raise MyError(f"Not a valid item type {TYPES}: {itemtype}")

    if itemtype == 'u':
        items = list(map(int, items))

    # Shortcut for 'set' and 'clear', as they don't require handling strlist
    if op == 'set':
        return itemtype, list(items)
    elif op in ('clear', 'new'):
        return itemtype, []

    # type annotation for empty lists: '@as []'
    if strlist.startswith('@'):
        strlist = strlist.split(' ', 1)[1]
        # TODO: maybe set itemtype too?

    try:
        curlist = ast.literal_eval(strlist)
    except (SyntaxError, ValueError):
        raise MyError(f"Malformed list literal: {strlist!r}")
    if not isinstance(curlist, list):
        raise MyError(f"Not a list literal: {strlist!r}")

    if op == 'remove':
        newlist = [_ for _ in curlist if _ not in items]
    elif op == 'include':
        newlist = curlist + [_ for _ in items if _ not in curlist]
    else:
        raise MyError(f"Not a valid list operation: {op!r}")

    return itemtype, newlist


try:
    if len(sys.argv) < 4:
        raise MyError(f"Missing required arguments in {sys.argv[1:]}.\n"
            f"Usage: {sys.argv[0]} OPERATION ITEM_TYPE LIST_STRING [ITEMS...]")
    itemtype, newlist = main(*sys.argv[1:])
    print(f'@a{itemtype} {newlist!r}')
    sys.exit()
except Exception as e:
    err = str(e) if isinstance(e, MyError) else repr(e)
    print(f'GVariant error: {err}', file=sys.stderr)
    sys.exit(1)
