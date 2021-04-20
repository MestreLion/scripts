Setup Library Extensions
========================

Directory for Bash libraries to extend [`setuplib`](../setuplib) functionality.

- Files here are sourced on-demand by [`setuplib`](../setuplib) on `include()`
  - It source files at `SETUP_LIB_DIR`, by default at `$(dirname setuplib)/setuplib.d`

- All function names **must** be prefixed to match the file name. Absolutely no exceptions!
  - Makes it possible to track where a given function was defined. As a bonus it avoids collisions.
  - No problem using cryptic names such as `nm`: the file header will have a description

- Main files should be extensionless, so scripts can source using `include name`
  - Support files, not meant for the scripts, can have an extension,
    such as [`gvariant.py`](./gvariant.py) used by [`gvariant`](./gvariant)

- Libraries can also `include` other libraries, and many do.

- While we *could* use import guards to prevent multiple sourcing, we do not.
   This is Bash, not C. And performance is irrelevant for one-shot setup scripts.
