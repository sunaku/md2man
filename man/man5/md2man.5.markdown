# MD2MAN 5 2016-02-13 5.0.1

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

The first top-level `<h1>` heading found in the input is considered to be the
`.TH` directive in roff(7), as described under "Title line" in man-pages(7):

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

## SEE ALSO

markdown(7), man-pages(7), md2man-roff(1), md2man-html(1), md2man-rake(1)

[md2man]: https://github.com/sunaku/md2man
[Redcarpet]: https://github.com/vmg/redcarpet
