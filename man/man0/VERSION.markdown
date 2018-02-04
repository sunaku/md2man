## Version 5.1.2 (2018-02-04)

### Patch:

  * md2man-roff(1): fix ordered list numbering for nested list items.

    Thanks to thinca for contributing this patch in pull request #27:
    https://github.com/sunaku/md2man/pull/27

### Other:

  * Upgrade to Rouge 3.0 for syntax highlighting.

  * Upgrade to Rake 12.0 for build automation.

## Version 5.1.1 (2016-03-04)

### Patch:

  * md2man-rake(1): "man" was both a folder name and a task name.

        rake/invocation_chain.rb:16:in `append': Circular dependency detected:
        TOP => md2man:man => man/test_markdown => man => md2man:man (RuntimeError)

    Thanks to David Dieulivol (@born4new) for reporting this issue:
    https://github.com/sunaku/md2man/issues/22

## Version 5.1.0 (2016-02-28)

### Minor:

  * md2man-html(1): add syntax highlighting to fenced code blocks.

  * md2man-rake(1): add directory name to README and "man/index" title.

    Fallback to adding directory name for standalone titles, such as "README"
    and "man/index", so that users know what project those manuals belong to.

  * md2man-rake(1): allow running task names without namespace.

    You can now run `md2man-rake man` instead of `md2man-rake md2man:man`,
    and similarly `md2man-rake web` instead of `md2man-rake md2man:web`.

### Patch:

  * Clarify optionalness of PATTERN in `--help` option.

  * md2man(5): paragraph types reflect .PP, .TP, .IP.

  * Link to Markdown website instead of markdown(7).

## Version 5.0.3 (2016-02-21)

This release fixes a crash, fixes roff bugs, improves CSS styling for HTML
output, and adds a complete manual page example in md2man(5) documentation.

### Patch:

  * Fix crash upon encountering a sole space ` ` or tab `	` in a codespan.

  * md2man-rake(1): fix sorting of manual pages in `man/index.html` listing.
    Previously, the manual page with longest filename ended up at the top.

  * md2man-html(1): emit extraneous top-level heading components that come
    after the known list of "title section date source manual" components.
    Previously, such extraneous components were omitted from the output.

  * md2man-html(1): &quot; escaping broke shellwords splitting of .TH heading.

  * md2man-html(1): css: hide title, section, manual in top-level heading.

  * md2man-html(1): css: center top-level heading; float source right.

  * md2man-roff(1): don't chomp off the newline at end of output.

  * md2man-roff(1): newline before links broke tagged paragraphs.

  * md2man-roff(1): don't squeeze newlines inside code blocks.

### Other:

  * md2man(5): revise paragraph definitions and add complete manpage example.

  * Document optional regexp argument to `-h` and `--help` in all executables.

  * README: "document format" was moved into md2man(5).

  * README: shorten and move project links to the top.

  * README: add link to pre-rendered example HTML file.

  * md2man-roff(1): we don't emit `.UM` and `.UE` directives anymore.

  * md2man-roff(1): add tests for postprocess document lstrip().

  * README: rename "Demonstration" section to "Examples".

  * README: move EXAMPLE.png screenshot into gh-pages branch.

## Version 5.0.1 (2016-02-13)

### Major:

  * `md2man-html` now puts permalinks _after_ heading text to avoid unsightly
    gaps at the beginning of each heading in text-mode browsers like w3m(1).

  * Upgrade to binman version 5.x.x, which is also a major version bump.

### Other:

  * README: use fenced code blocks to get syntax highlighting on GitHub.

## Version 4.0.1 (2016-02-10)

### Other:

  * Make all permalinks appear in the same size.

  * Change permalink symbols from hearts to stars.

  * Indicate target heading with a red permalink.

## Version 4.0.0 (2014-10-26)

### Major:

  * Cross references are no longer expanded inside code spans and code blocks.

    Thanks to Mathias Panzenböck for reporting this issue in GH-19:
    https://github.com/sunaku/md2man/issues/19

  * The `Md2Man::Document` module now defines the following methods.  If you
    redefine/override these methods in deriving classes, make sure that you
    call `super()` therein to trigger these methods' original implementation!

    * `Md2Man::Document#block_code(code, language)`
    * `Md2Man::Document#codespan(code)`

## Version 3.0.2 (2014-10-26)

### Patch:

  * Update bootstrap 2.3.2 CDN URL; previous one died.

## Version 3.0.1 (2014-07-16)

This release restores Mac OS X support and fixes a permalink generation bug.

### Patch:

  * GH-13: man(1) on Mac OS X could not display URLs.

    The version of groff on Mac OS X is too old: it lacks the an-ext.tmac
    macro package that defines styles for email addresses and general URLs.

        $ groff --version
        ...
        GNU grops (groff) version 1.19.2
        GNU troff (groff) version 1.19.2

    This patch drops those URL macros in favor of simpler angled brackets.

    Thanks to Sorin Ionescu for reporting this issue in GH-13:
    https://github.com/sunaku/md2man/issues/13

  * md2man-html(1): cross references were escaped in heading permalink IDs.

## Version 3.0.0 (2014-06-22)

This release changes md2man-html(1) heading permalinks to follow GitHub style:
unique, lowercase, and squeezed and stripped of HTML tags and non-word chars.
In addition, it renames the `md2man-xref` CSS class to `md2man-reference`.

Please make sure to update any existing bookmarks and/or hyperlinks you may
have for jumping to specific locations in your HTML manuals after upgrading.

### Major:

  * Make permalink anchors on headings fully lowercase in md2man-html(1).

  * Put permalinks on left & indicate target permalink in md2man-html(1).

  * Make permalink anchors unique by appending a count in md2man-html(1).

  * Rename `md2man-xref` CSS class to `md2man-reference` in md2man-html(1).

## Version 2.1.1 (2014-06-21)

### Patch:

  * Bootstrap CSS failed to load for HTML manuals served under HTTPS.
    See <https://github.com/sunaku/readably/pull/3> for the details.

  * Drop redundant nil check in `Md2Man::Roff::Engine.escape()`.

### Other:

  * GitHub now supports relative links from the README.

  * README: add links to package, manuals, and GitHub.

## Version 2.1.0 (2014-05-04)

### Minor:

  * md2man-html(1) now adds anchors and permalinks to all headings.  This
    makes it easy for readers to bookmark and share direct links to specific
    sections of your HTML manual pages.

  * md2man-html(1) now wraps individual components of the special `.TH`
    top-level heading in HTML `<span>` elements with stylable CSS classes:

        <span class="md2man-title">...</span>
        <span class="md2man-section">...</span>
        <span class="md2man-date">...</span>
        <span class="md2man-source">...</span>
        <span class="md2man-manual">...</span>

    Thanks to Nick Fagerlund for requesting this feature in [GH-15](
    https://github.com/sunaku/md2man/issues/15 ).

### Other:

  * md2man(5) now documents the special `.TH` format of top-level headings.

    Thanks to Nick Fagerlund for requesting this documentation in [GH-15](
    https://github.com/sunaku/md2man/issues/15 ).

## Version 2.0.4 (2014-04-26)

### Patch:

  * GH-16: Redcarpet 3.1 added a third parameter to its `header()` method.
    This raised an ArgumentError on "wrong number of arguments (3 for 2)".

    Thanks to zimbatm for contributing this patch.

  * GH-17 and GH-18: Escape periods, quotes, and hyphens in code blocks.
    This fixes a bug where lines beginning with periods or single quotes
    did not appear when md2man-roff(1) output was rendered using man(1).

    Thanks to zimbatm for reporting this bug and suggesting how to fix it.

## Version 2.0.3 (2014-01-16)

### Patch:

  * Use CSS3 `-ch` suffix for accurate 80-character width in HTML output.

    http://www.w3.org/TR/css3-values/#font-relative-lengths

## Version 2.0.2 (2013-09-08)

Patch:

  * GH-14: escape single quotes at beginning of lines

    See the "CONTROL CHARACTERS" section in the groff(7) manual for details.

    Thanks to Nick Fagerlund for reporting this bug.

  * escape periods at line beginnings with \& escape

  * escape text line backslashes as "\e" per groff(7)

  * better documentation for escaping in normal_text()

  * it's better to escape backslashes as \[rs] than \e

    See "Single-Character Escapes" section in groff(7).

Other:

  * switch from double-quoted strings to single quotes

## Version 2.0.1 (2013-08-29)

Patch:

  * Use a proper CDN to access Bootstrap 2.3.2 styling in HTML output.

  * Ensure that man/ directory exists for the `md2man:web` Rake task.

  * Specify license in gemspec file to fix warning when building gem.

    Thanks to Bastien Dejean for contributing this patch.

Other:

  * Upgrade dependent gems by running `bundle update`.

  * minitest 4.7.5 provides spec library via autorun.

## Version 2.0.0 (2013-05-05)

This release renames md2man executables and libraries to highlight the fact
that md2man provides two processing pathways: one for Roff and one for HTML.

Major:

  * Rename md2man(1) executable to md2man-roff(1).

  * Rename `Md2Man::Engine` to `Md2Man::Roff::Engine`.

  * Rename "manpage-reference" CSS class to "md2man-xref" in HTML output.

  * The `Md2Man::Document#reference()` method now takes only two parameters:

    * `input_match` - MatchData object for the reference in Markdown input
      containing the following named capture groups:

      * `:page` - name of the manual page

      * `:section` - section number of the manual page

    * `output_match` - MatchData object for the reference in output document
      containing the following named capture groups:

      * `:addendum` - non-space characters immediately after the reference in
        the output document

Patch:

  * Prevent cross-references from being expanded inside HTML tags.

Other:

  * Add md2man(5) manual page detailing md2man's markdown file format.

## Version 1.6.2 (2013-05-05)

Patch:

  * Fix "uninitialized constant Md2Man::VERSION" error in `md2man/rakefile`.

  * HTML manual page CSS: justify the lines of text just like man(1) does.

  * HTML manual page CSS: resize body to allot 78ex width for manpage text.

## Version 1.6.1 (2013-05-04)

Patch:

  * Replace multi-column CSS with single centered body.

Other:

  * Fix manpage xrefs in README and VERSION documents.

## Version 1.6.0 (2013-03-10)

Minor:

  * Added an md2man-rake(1) executable that lets you run md2man's rake(1)
    tasks _directly_ from the command line: without the need for a "Rakefile"
    in your working directory that loads the `md2man/rakefile` library.

  * In web pages generated by the `md2man:web` Rake task:

    * extract CSS into a separate `man/style.css` file

    * center manpage on screen & auto-split into columns

Patch:

  * In web pages generated by the `md2man:web` Rake task:

    * don't rely on being emitted into a `man/` directory

Other:

  * add README and VERSION to generated HTML man pages

## Version 1.5.1 (2013-03-06)

Patch:

  * All this time, this project's documentation stated that Redcarpet's
    `no_intra_emphasis` option was enabled, but in reality, it was not.
    The documentation has been corrected and the option remains disabled.

  * In web pages generated by the `md2man:web` Rake task:

    * deactivate cross references to external manual pages

    * don't assume that NAME section contains a tagline

    * sort man/ subdirectories in the HTML index page

    * fix link to index page from webs directly in man/

    * add generator META tag to HTML output template

    * only apply special styling to the first H1 child

    * parse title from first paragraph containing hyphen

Other:

  * rename HISTORY to VERSION so it sorts after README

  * tests should exercise engines with default options

## Version 1.5.0 (2013-02-24)

Minor:

  * The `md2man:web` task from `md2man/rakefile` now:

    * emits valid HTML5 with helpful HTML page titles

    * uses Twitter Bootstrap styling for HTML man pages

    * emits only ONE index page for all HTML man pages

Other:

  * README: better organize the subsections of "Usage"

  * include md2man rake tasks in developer's rakefile

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
