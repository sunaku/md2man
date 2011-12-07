md2man - write UNIX man pages in Markdown
==============================================================================

md2man is a Ruby library and command-line program that converts [Markdown]
documents into UNIX man pages (really [Roff] documents) using [Redcarpet2].

[Roff]: http://troff.org
[Markdown]: http://daringfireball.net/projects/markdown/
[Redcarpet2]: https://github.com/tanoku/redcarpet

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

md2man introduces the following additions to the core [Markdown] language:

  * If a paragraph's first or subsequent lines are uniformly indented by two
    spaces, then it is considered to be a "tagged paragraph" and its body is
    unindented before being emitted under a `.TP` macro in the [Roff] output.

    For example, the following [Markdown] input:

        This is a
        normal paragraph.

        This is a
          tagged paragraph.

          This is another
        tagged paragraph.

          This is yet another
          tagged paragraph.

        This
         is another
          normal
           paragraph.

    Yields the following [Roff] output:

        .PP
        This is a
        normal paragraph.
        .TP
        This is a
        tagged paragraph.
        .TP
        This is another
        tagged paragraph.
        .TP
        This is yet another
        tagged paragraph.
        .PP
        This
         is another
          normal
           paragraph.

    Which appears like the following:

      >This is a
      >normal paragraph.
      >
      >>This is a
      >>tagged paragraph.
      >
      >>This is another
      >>tagged paragraph.
      >
      >>This is yet another
      >>tagged paragraph.
      >
      >This
      > is another
      >  normal
      >   paragraph.

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
