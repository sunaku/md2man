RedcarpetManpage - UNIX man page renderer for Redcarpet2
========================================================

RedcarpetManpage is a Ruby library that converts [Markdown] documents into
UNIX man pages ([roff] documents) using the awesome [Redcarpet2] library.

[Markdown]: http://daringfireball.net/projects/markdown/
[roff]: http://man.cx/roff(7)
[Redcarpet2]: https://github.com/tanoku/redcarpet

------------------------------------------------------------------------------
Installation
------------------------------------------------------------------------------

As a Ruby gem:

    gem install redcarpet-manpage

As a Git clone:

    git clone git://github.com/sunaku/redcarpet-manpage
    cd redcarpet-manpage
    bundle install

------------------------------------------------------------------------------
Specification
------------------------------------------------------------------------------

### Markdown Processing Extensions

`RedcarpetManpage::RENDERER` enables the following [Redcarpet2] extensions:

* `autolink`
* `no_intra_emphasis`
* `fenced_code_blocks`
* `space_after_headers`

### Markdown Processing Divergence

Although your input documents are written in [Markdown], RedcarpetManpage
introduces the following additional conventions to simplify common tasks:

1. Paragraphs beginning with bold/italic and followed by a two-space indented
   line are considered to be definitions.  The first line of such a paragraph
   is the term being defined and the subsequent two-space indented lines are
   the definition body.

2. Paragraphs beginning with a two-space indented line are considered to be a
   part of multi-paragraph definitions.

------------------------------------------------------------------------------
Usage
------------------------------------------------------------------------------

Use the default renderer:

``` ruby
require 'redcarpet-manpage'
your_roff_output = RedcarpetManpage::RENDERER.render(your_markdown_input)
```

Or extend it for yourself:

``` ruby
require 'redcarpet-manpage'

class YourManpageRenderer < RedcarpetManpage::Renderer
  # ... your stuff here ...
  # See Redcarpet::Render::Base documentation for more information:
  # http://rdoc.info/github/tanoku/redcarpet/master/Redcarpet/Render/Base
end

renderer = Redcarpet::Markdown.new(YourManpageRenderer, your_options_hash)
your_roff_output = renderer.render(your_markdown_input)
```

------------------------------------------------------------------------------
License
------------------------------------------------------------------------------

Released under the ISC license.  See the LICENSE file for details.
