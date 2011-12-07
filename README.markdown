md2man - write UNIX man pages in Markdown
==============================================================================

md2man is a Ruby library and command-line program that converts [Markdown]
documents into UNIX man pages (really [Roff] documents) using [Redcarpet2].

[Roff]: http://troff.org
[Markdown]: http://daringfireball.net/projects/markdown/
[Redcarpet2]: https://github.com/tanoku/redcarpet
[example]: https://raw.github.com/sunaku/md2man/master/EXAMPLE.markdown

------------------------------------------------------------------------------
Demonstration
------------------------------------------------------------------------------

Try converting [this example Markdown file][example] into a UNIX man page:

    md2man EXAMPLE.markdown | man -l -

![Obligatory screenshot of md2man(1) in action!](http://ompldr.org/vYnFvbw)

------------------------------------------------------------------------------
Installation
------------------------------------------------------------------------------

As a Ruby gem:

    gem install md2man

As a Git clone:

    git clone git://github.com/sunaku/md2man
    cd md2man
    bundle install

------------------------------------------------------------------------------
Command Usage
------------------------------------------------------------------------------

Read the manual page:

    md2man --help

------------------------------------------------------------------------------
Library Usage
------------------------------------------------------------------------------

Use the default renderer:

    require 'md2man'
    your_roff_output = Md2Man::ENGINE.render(your_markdown_input)

Build your own renderer:

    require 'md2man'
    engine = Redcarpet::Markdown.new(Md2Man::Engine, your_options_hash)
    your_roff_output = engine.render(your_markdown_input)

Define your own renderer:

    require 'md2man'

    class YourManpageRenderer < Md2Man::Engine
      # ... your stuff here ...
    end

    engine = Redcarpet::Markdown.new(YourManpageRenderer, your_options_hash)
    your_roff_output = engine.render(your_markdown_input)

Mix-in your own renderer:

    require 'md2man'

    class YourManpageRenderer < Redcarpet::Render::Base
      include Md2Man::Roff
      # ... your stuff here ...
    end

    engine = Redcarpet::Markdown.new(YourManpageRenderer, your_options_hash)
    your_roff_output = engine.render(your_markdown_input)

------------------------------------------------------------------------------
Document Format
------------------------------------------------------------------------------

md2man attaches the following additional semantics to its [Markdown] input:

  * There can be at most one top-level heading (H1).  It is emitted as `.TH`
    in the [Roff] output, specifying the UNIX man page's header and footer.

  * Paragraphs whose lines are all uniformly indented by two spaces are
    considered to be "indented paragraphs".  They are unindented accordingly
    before emission as `.IP` in the [Roff] output.

  * Paragraphs whose subsequent lines (all except the first) are uniformly
    indented by two spaces are considered to be a "tagged paragraphs".  They
    are unindented accordingly before emission as `.TP` in the [Roff] output.

------------------------------------------------------------------------------
Limitations
------------------------------------------------------------------------------

At present, md2man does not translate the following [Redcarpet2] node types:

  * `block_html`
  * `strikethrough`
  * `superscript`
  * `image`
  * `raw_html`

It issues a warning when it encounters these instead.  Patches are welcome!

------------------------------------------------------------------------------
License
------------------------------------------------------------------------------

Released under the ISC license.  See the LICENSE file for details.
