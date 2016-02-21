# MD2MAN 5                        2016-02-21                            5.0.2

## NAME

md2man - UNIX manual page flavoring for the markdown(7) file format

## DESCRIPTION

[md2man] makes the markdown(7) file format friendly for writing UNIX manual
pages by extending its syntax, semantics, and assumed processing extensions.

### Syntax

md2man extends markdown(7) syntax by distinguishing three kinds of paragraphs.

#### Normal paragraphs

Paragraphs whose lines are all indented by exactly zero or one additional
spaces are considered to be "normal paragraphs".  For example:

    This is a normal paragraph.

    This is also
    a normal
    paragraph.

    And
    this
     is
     a
      normal
       paragraph
        too.

#### Tagged paragraphs

Paragraphs whose first line is indented by less than two additional spaces and
whose subsequent lines are uniformly indented by exactly two additional spaces
are considered to be "tagged paragraphs".  For example:

    This is a
      tagged
      paragraph.

#### Indented paragraphs

Paragraphs whose lines are all uniformly indented by exactly two additional
spaces are considered to be "indented paragraphs".  For example:

      This is an
      indented
      paragraph.

### Semantics

md2man extends markdown(7) semantics by treating top-level headings specially.

#### Top-level headings

The first top-level `<h1>` heading found in the input is considered to be the
`.TH` directive in roff(7), described under "Title line" in man-pages(7) thus:

>     .TH title section date source manual
>
> title
>   The title of the man page, written in all caps (e.g., `MAN-PAGES`).
>
> section
>   The section number in which the man page should be placed (e.g., `7`).
>
> date
>   The date of the last revision, written in the form YYYY-MM-DD.
>
> source
>   The source of the command, function, or system call (e.g., `Linux`).
>
> manual
>   The title of the manual (e.g., `Linux Programmer's Manual`).

Any subsequent top-level headings are treated as second-level `<h2>` headings.

### Extensions

md2man enables the following [Redcarpet] extensions while reading markdown(7):

  * tables
  * autolink
  * superscript
  * strikethrough
  * fenced\_code\_blocks

### Examples

Below is a complete example of an md2man(5) formatted manual page adapted from
the [Linux Man Page Howto](http://www.schweikhardt.net/man_page_howto.html)
guide by Jens Schweikhardt.  [The result of processing](../man0/EXAMPLE.html)
this example with md2man-html(1) has been bundled along with this manual page.

```markdown
FOO 1 "MARCH 1995" Linux "User Manuals"
=======================================

NAME
----

foo - frobnicate the bar library

SYNOPSIS
--------

`foo` [`-bar`] [`-c` *config-file*] *file* ...

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
```

## SEE ALSO

markdown(7), man-pages(7), md2man-roff(1), md2man-html(1), md2man-rake(1)

[md2man]: https://github.com/sunaku/md2man
[Redcarpet]: https://github.com/vmg/redcarpet
