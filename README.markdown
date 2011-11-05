Redman - UNIX man pages in Markdown
==============================================================================

Redman is a Ruby library for converting [Markdown] documents into UNIX man
pages ([Roff] documents) using the awesome [Redcarpet2] library.

[Roff]: http://troff.org
[Markdown]: http://daringfireball.net/projects/markdown/
[Redcarpet2]: https://github.com/tanoku/redcarpet

------------------------------------------------------------------------------
Installation
------------------------------------------------------------------------------

As a Ruby gem:

    gem install redman

As a Git clone:

    git clone git://github.com/sunaku/redman
    cd redman
    bundle install

------------------------------------------------------------------------------
Usage
------------------------------------------------------------------------------

Use the default renderer:

    require 'redman'
    markdown = Redcarpet::Markdown.new(Redman::Roff, your_options_hash)
    your_roff_output = markdown.render(your_markdown_input)

Or extend it for yourself:

    require 'redman'

    class YourManpageRenderer < Redman::Roff
      # ... your stuff here ...
      # See Redcarpet::Render::Base documentation for more information:
      # http://rdoc.info/github/tanoku/redcarpet/master/Redcarpet/Render/Base
    end

    markdown = Redcarpet::Markdown.new(YourManpageRenderer, your_options_hash)
    your_roff_output = markdown.render(your_markdown_input)

------------------------------------------------------------------------------
Specification
------------------------------------------------------------------------------

Redman introduces the following additions to the core [Markdown] language:

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

At present, Redman does not translate the following [Redcarpet2] node types:

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
