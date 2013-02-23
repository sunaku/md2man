## Version 1.4.1 (2013-02-23)

Patch:

  * rakefile: arbitrary directory structure under man/

    https://github.com/sunaku/md2man/pull/3#issuecomment-9429077

    Thanks to Postmodern for raising this issue.

  * hook into 'build' task only if using Bundler tasks

    https://github.com/sunaku/md2man/pull/7#issuecomment-9467621

    Thanks to Postmodern for raising this issue.

  * GH-8: Redcarpet requires Ruby 1.9 and so must we

    https://github.com/sunaku/md2man/issues/8#issuecomment-9509240

    Thanks to Postmodern for raising this issue.

Other:

  * README: add md2man-html(1) and Md2Man::HTML usage

  * LICENSE: use GitHub profile URLs instead of e-mail

## Version 1.4.0 (2012-10-14)

Minor:

  * roff: emit non-first H1 headings as H2 headings

  * html: add `Md2Man::HTML::Engine` class for HTML manual page generation

  * html: add md2man-html(1) bin script for command line access to the above

  * html: add ID attributes on all headings for easy permalinking

  * rake: add `md2man/rakefile` to process markdown files in man/

    This library provides a `rake md2man` task that builds UNIX and HTML
    manual pages from Markdown files (with ".markdown", ".mkd", or ".md"
    extension) inside your `man/man*/` directories.  It also provides
    sub-tasks to build *only* UNIX or HTML manual pages separately.

    It also hooks into Bundler's gem packaging tasks to automatically build
    your manual pages for packaging into a gem.  See the README for details.

## Version 1.3.2 (2012-10-13)

Patch:

  * roff: escape backslashes inside codespan nodes too

  * roff: escape backslashes inside block\_code nodes

## Version 1.3.1 (2012-10-09)

Patch:

  * roff: do not render references inside code blocks.

  * roff: do not render references inside code spans.

  * roff: fix single-line indented paragraph detection.

  * roff: also indent block\_code just like block\_quote.

  * roff: add paragraph above block\_quote for spacing.

  * roff: render code blocks as paragraphs for spacing.

    Otherwise there's not enough space between the previous paragraph and
    the code block: it appears on the next line and appears ugly in man(1).

  * document: make reference regexp match more manpages.

Other:

  * document: stronger digest encoding using NUL bytes.

  * document: super() can't reach Redcarpet's renderer classes.
    See https://github.com/vmg/redcarpet/issues/51 for details.

## Version 1.3.0 (2012-09-27)

Minor:

  * Intra-word emphasis is now enabled *by default* in `Md2Man::ENGINE`.
    To not be affected by this change, you may still construct your own
    Redcarpet::Markdown engine with your own set of processing options.

## Version 1.2.1 (2012-07-05)

Patch:

  * GH-4: ruby 1.8.7 lacks negative lookbehind regexps.
    Thanks to Postmodern for reporting this issue.

Other:

  * GH-1: use `~>` for gem version constraints.
    See http://docs.rubygems.org/read/chapter/16
    Thanks to Postmodern for this contribution.

## Version 1.2.0 (2012-02-06)

Minor:

  * The `Md2Man::Document` module now handles paragraph() nodes and dispatches
    their content accordingly to hook methods for indented, tagged, and normal
    paragraphs.  A Redcarpet markdown parser need only include that module and
    implement those hook methods in order to benefit from md2man's extensions
    to markdown syntax programmatically.

Other:

  * README: mention features; revise markdown; cleanup.

  * LICENSE: @tanoku created initial Manpage renderer.

## Version 1.1.0 (2012-02-02)

Minor:

  * Add `Md2Man::Document` module for programmatic processing of
    cross-references to other UNIX manual pages within Redcarpet.

Other:

  * README: not all systems support `man -l` option.

  * gemspec: upgrade to redcarpet 2.1.0.

  * bundler suggests moving all dev deps into gemspec.

  * README: fix installation commands for development.

  * README: simplify project slogan to be more memorable.

## Version 1.0.2 (2012-01-09)

Patch:

  * Blockquote's leading paragraph regexp was not anchored.

  * Freezing internal constants prevents monkey patching.

Other:

  * Upgraded to Binman 3 for better interoperability with Bundler.

  * Added example input file from the Linux Man Page Howto.

  * Forgot to change project slogan in the gem package.

## Version 1.0.1 (2011-12-06)

Major:

  * Renamed the project from "redcarpet-manpage" to "md2man".

    * `RedcarpetManpage::Renderer` is now `Md2Man::Engine`.

    * `RedcarpetManpage::RENDERER` is now `Md2Man::ENGINE`.

  * Tagged paragraphs no longer require the first line to begin with italic or
    bold styling.  All that matters is that the subsequent lines are indented.

Minor:

  * Added md2man(1) executable for command-line usage.

  * Added support for all HTML 4.0 and XHTML 1.0 entities.

  * Added support for tables, horizontal rules, and more.

  * Added `Md2Man::Roff` mixin for advanced Redcarpet2 usage.

  * Improved README with some new and revised documentation.

Other:

  * Rewrote entire Markdown to Roff conversion from scratch while doing TDD.

## Version 0.0.1 (2011-10-13)

First release! Happy birthday! Woohoo! :-)
