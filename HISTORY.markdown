------------------------------------------------------------------------------
Version 1.1.0 (2012-02-02)
------------------------------------------------------------------------------

Improvements:

  * Add `Md2Man::Document` module for programmatic processing of
    cross-references to other UNIX manual pages within Redcarpet.

Housekeeping:

  * README: not all systems support `man -l` option.

  * gemspec: upgrade to redcarpet 2.1.0.

  * bundler suggests moving all dev deps into gemspec.

  * README: fix installation commands for development.

  * README: simplify project slogan to be more memorable.

------------------------------------------------------------------------------
Version 1.0.2 (2012-01-09)
------------------------------------------------------------------------------

Corrections:

  * Blockquote's leading paragraph regexp was not anchored.

  * Freezing internal constants prevents monkey patching.

Housekeeping:

  * Upgraded to Binman 3 for better interoperability with Bundler.

  * Added example input file from the Linux Man Page Howto.

  * Forgot to change project slogan in the gem package.

------------------------------------------------------------------------------
Version 1.0.1 (2011-12-06)
------------------------------------------------------------------------------

Divergences:

  * Renamed the project from "redcarpet-manpage" to "md2man".

    * `RedcarpetManpage::Renderer` is now `Md2Man::Engine`.

    * `RedcarpetManpage::RENDERER` is now `Md2Man::ENGINE`.

  * Tagged paragraphs no longer require the first line to begin with italic or
    bold styling.  All that matters is that the subsequent lines are indented.

Improvements:

  * Added md2man(1) executable for command-line usage.

  * Added support for all HTML 4.0 and XHTML 1.0 entities.

  * Added support for tables, horizontal rules, and more.

  * Added `Md2Man::Roff` mixin for advanced Redcarpet2 usage.

  * Improved README with some new and revised documentation.

Housekeeping:

  * Rewrote entire Markdown to Roff conversion from scratch while doing TDD.

------------------------------------------------------------------------------
Version 0.0.1 (2011-10-13)
------------------------------------------------------------------------------

First release! Happy birthday! Woohoo! :-)
