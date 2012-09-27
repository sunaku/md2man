# md2man - markdown to manpage

md2man is a Ruby library and command-line program that converts [Markdown]
documents into UNIX manual pages (really [Roff] documents) using [Redcarpet].

## Features

  * Formats tagged and indented paragraphs (see "document format" below).

  * Translates all HTML4 and XHTML1 entities into native Roff equivalents.

  * Supports markdown extensions such as [PHP Markdown Extra tables][tables].

  * Usable from the command line as a filter in a UNIX pipeline.

### Demonstration

Try converting [this example Markdown file][example] into a UNIX manual page:

    md2man EXAMPLE.markdown > EXAMPLE.1
    man EXAMPLE.1

![Obligatory screenshot of md2man(1) in action!](http://ompldr.org/vYnFvbw)

### Limitations

At present, md2man does not translate the following [Redcarpet] node types:

  * `block_html`
  * `strikethrough`
  * `superscript`
  * `image`
  * `raw_html`

It issues a warning when it encounters these instead.  Patches are welcome!

## Installation

    gem install md2man

### Development

    git clone git://github.com/sunaku/md2man
    cd md2man
    bundle install --binstubs=bundle_bin
    bundle_bin/md2man --help  # run it directly
    bundle exec rake -T       # packaging tasks

## Usage

### At the command line

    md2man --help

### Inside a Ruby script

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

### Document format

md2man extends [Markdown] syntax in the following ways, as provisioned in the
`Md2Man::Document` module and defined in its derivative `Md2Man::Roff` module:

  * Paragraphs whose lines are all uniformly indented by two spaces are
    considered to be "indented paragraphs".  They are unindented accordingly
    before emission as `.IP` in the [Roff] output.

  * Paragraphs whose subsequent lines (all except the first) are uniformly
    indented by two spaces are considered to be a "tagged paragraphs".  They
    are unindented accordingly before emission as `.TP` in the [Roff] output.

md2man extends [Markdown] semantics in the following ways:

  * There can be at most one top-level heading (H1).  It is emitted as `.TH`
    in the [Roff] output, defining the UNIX manual page's header and footer.

## License

Released under the ISC license.  See the LICENSE file for details.

[Roff]: http://troff.org
[Markdown]: http://daringfireball.net/projects/markdown/
[Redcarpet]: https://github.com/vmg/redcarpet
[example]: https://raw.github.com/sunaku/md2man/master/EXAMPLE.markdown
[tables]: http://michelf.com/projects/php-markdown/extra/#table
