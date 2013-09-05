# MD2MAN 5 2013-08-29 2.0.1

## NAME

md2man - manual page flavoring for the markdown(7) file format

## DESCRIPTION

[md2man] makes the markdown(7) file format friendly for writing UNIX manual
pages by extending its syntax, semantics, and assumed processing extensions.

### Syntax

md2man extends markdown(7) syntax by defining three kinds of paragraphs.

    This is a
    normal
    paragraph.

    This is a
      tagged
      paragraph.

      This is an
      indented
      paragraph.

    This
     is another
      normal
       paragraph.

#### Normal paragraphs

Paragraphs whose lines are all indented by exactly zero or one additional
spaces are considered to be "normal paragraphs".  For example:

    This is a
    normal
    paragraph.

    This
     is another
      normal
       paragraph.

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

The first top-level heading (H1) found in the input is considered to be the
`.TH` directive in roff(7), which defines the UNIX manual page's header and
footer.  Any subsequent top-level headings are treated as second-level (H2).

#### First top-level heading

    # manpage-name manpage-section center-footer left-footer center-header

manpage-name
  The name of the command or function.

manpage-section
  The section number of the manual. (1 for commands, etc.)

center-footer
  The date the man page was last modified. Some systems do not display footers
  when you use the man command interactively, only when printing the pages.

left-footer
  Bottom left footer.  See below.

center-header
  The main page (center) heading.  See below.

Use quotes if any of these fields contains embedded blanks. Use "CS-701" as
the left-footer for the man pages you write for this course. The main page
(center) heading gives the place or organization where the software being
documented originated; we'll use "Queens College."

Here is an example:

    # mycommand 1 "December 2001" "CS-701" "Queens College"

### Extensions

md2man enables the following [Redcarpet] extensions while reading markdown(7):

  * tables
  * autolink
  * superscript
  * strikethrough
  * fenced\_code\_blocks

## SEE ALSO

markdown(7), md2man-roff(1), md2man-html(1), md2man-rake(1)

[md2man]: https://github.com/sunaku/md2man
[Redcarpet]: https://github.com/vmg/redcarpet
