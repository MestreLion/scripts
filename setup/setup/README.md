Setup Scripts
===============

All scripts must:

- Be **idempotent**, called multiple times without affecting the system after the first run

- Have no required arguments, to allow running in batch mode without any arguments.
  - Arguments **must** be allowed to be set from a shell or environment variable,
     so they can be sourced from a config file (`setuplib` takes care of that).
     The command-line value takes precedence, obviously.
  - The expected variable **must** be prefixed as `SETUP_SCRIPTNAME_VARNAME_...`
  - In a nutshell: `myvar=${1:-SETUP_MYNAME_MYVAR:-"default"}`.
  - Values must have a sane, sensible, default value so scripts _Just Works®_.
  - When a default value cannot be reasonably defined, such as passwords and
     email addresses, scripts _can_ require them to be set in the config file.
     Use `argument()` for this: `var=${1:-SETUP_NAME_VAR:-}; argument VAR`.
     (`required()` was already taken, sorry).

- Use the boilerplate [`template`](template) as the standard way to source [`setuplib`](../setuplib)
