FOO 1 "MARCH 1995" Linux "User Manuals"
=======================================

NAME
----

foo - frobnicate the bar library

SYNOPSIS
--------

`foo` [`-bar`] [`-c` *config-file* ] *file* ...

DESCRIPTION
-----------

`foo` frobnicates the bar library by tweaking internal symbol tables. By
default it parses all baz segments and rearranges them in reverse order by
time for the xyzzy(1) linker to find them. The symdef entry is then compressed
using the WBG (Whiz-Bang-Gizmo) algorithm. All files are processed in the
order specified.

OPTIONS
-------

`-b`
  Do not write "busy" to stdout while processing.

`-c` *config-file*
  Use the alternate system wide *config-file* instead of */etc/foo.conf*. This
  overrides any `FOOCONF` environment variable.

`-a`
  In addition to the baz segments, also parse the blurfl headers.

`-r`
  Recursive mode. Operates as fast as lightning at the expense of a megabyte
  of virtual memory.

FILES
-----

*/etc/foo.conf*
  The system wide configuration file. See foo(5) for further details.

*~/.foorc*
  Per user configuration file. See foo(5) for further details.

ENVIRONMENT
-----------

`FOOCONF`
  If non-null the full pathname for an alternate system wide */etc/foo.conf*.
  Overridden by the `-c` option.

DIAGNOSTICS
-----------

The following diagnostics may be issued on stderr:

**Bad magic number.**
  The input file does not look like an archive file.

**Old style baz segments.**
  `foo` can only handle new style baz segments. COBOL object libraries are not
  supported in this version.

BUGS
----

The command name should have been chosen more carefully to reflect its
purpose.

AUTHOR
------

Jens Schweikhardt <howto@schweikhardt.net>

SEE ALSO
--------

bar(1), foo(5), xyzzy(1), [Linux Man Page Howto](
http://www.schweikhardt.net/man_page_howto.html)
