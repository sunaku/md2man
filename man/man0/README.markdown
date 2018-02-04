* Code: <https://github.com/sunaku/md2man>
* Docs: <https://sunaku.github.io/md2man/man>
* Bugs: <https://github.com/sunaku/md2man/issues>

# md2man - markdown to manpage

md2man is a Ruby library and a set of command-line programs that convert
[Markdown] into UNIX manpages as well as HTML webpages using [Redcarpet].

## Features

  * Formats indented, tagged, and normal paragraphs: described in md2man(5).

  * Translates all HTML4 and XHTML1 entities into native [roff] equivalents.

  * Supports markdown extensions such as [PHP Markdown Extra tables][tables].

  * Usable from the command line as a filter in a UNIX command pipeline.

### Examples

Try converting
[this example Markdown file][example]
into
[a UNIX manual page][example-roff]:

```sh
md2man-roff EXAMPLE.markdown > EXAMPLE.1
```

You can view [the resulting UNIX manual page][example-roff] in your man(1)
viewer:

```sh
man -l EXAMPLE.1
```

![screenshot](https://github.com/sunaku/md2man/raw/gh-pages/EXAMPLE.png)

Next, try converting
[the same example file][example]
into
[a HTML web page][example-html]:

```sh
md2man-html EXAMPLE.markdown > EXAMPLE.html
```

You can view [the resulting HTML manual page][example-html] in your web
browser:

```sh
firefox EXAMPLE.html
```

[example]: https://raw.github.com/sunaku/md2man/master/EXAMPLE.markdown
[example-roff]: https://github.com/sunaku/md2man/raw/gh-pages/man/man0/EXAMPLE
[example-html]: https://sunaku.github.io/md2man/man/man0/EXAMPLE.html

## Installation

```sh
gem install md2man
```

### Development

```sh
git clone https://github.com/sunaku/md2man
cd md2man
bundle install
bundle exec rake --tasks        # packaging tasks
bundle exec md2man-roff --help  # run it directly
bundle exec md2man-html --help  # run it directly
```

## Usage

### For [roff] output

#### At the command line

See md2man-roff(1) manual:

```sh
md2man-roff --help
```

#### Inside a Ruby script

Use the default renderer:

```ruby
require 'md2man/roff/engine'

your_roff_output = Md2Man::Roff::ENGINE.render(your_markdown_input)
```

Build your own renderer:

```ruby
require 'md2man/roff/engine'

engine = Redcarpet::Markdown.new(Md2Man::Roff::Engine, your_options_hash)
your_roff_output = engine.render(your_markdown_input)
```

Define your own renderer:

```ruby
require 'md2man/roff/engine'

class YourManpageRenderer < Md2Man::Roff::Engine
  # ... your stuff here ...
end

engine = Redcarpet::Markdown.new(YourManpageRenderer, your_options_hash)
your_roff_output = engine.render(your_markdown_input)
```

Mix-in your own renderer:

```ruby
require 'md2man/roff'

class YourManpageRenderer < Redcarpet::Render::Base
  include Md2Man::Roff
  # ... your stuff here ...
end

engine = Redcarpet::Markdown.new(YourManpageRenderer, your_options_hash)
your_roff_output = engine.render(your_markdown_input)
```

### For HTML output

#### At the command line

See md2man-html(1) manual:

```sh
md2man-html --help
```

#### Inside a Ruby script

Use the default renderer:

```ruby
require 'md2man/html/engine'

your_html_output = Md2Man::HTML::ENGINE.render(your_markdown_input)
```

Build your own renderer:

```ruby
require 'md2man/html/engine'

engine = Redcarpet::Markdown.new(Md2Man::HTML::Engine, your_options_hash)
your_html_output = engine.render(your_markdown_input)
```

Define your own renderer:

```ruby
require 'md2man/html/engine'

class YourManpageRenderer < Md2Man::HTML::Engine
  # ... your stuff here ...
end

engine = Redcarpet::Markdown.new(YourManpageRenderer, your_options_hash)
your_html_output = engine.render(your_markdown_input)
```

Mix-in your own renderer:

```ruby
require 'md2man/html'

class YourManpageRenderer < Redcarpet::Render::Base
  include Md2Man::HTML
  # ... your stuff here ...
end

engine = Redcarpet::Markdown.new(YourManpageRenderer, your_options_hash)
your_html_output = engine.render(your_markdown_input)
```

### Building manpages

#### At the command line

See md2man-rake(1) manual:

```sh
md2man-rake --help
```

#### Inside a Ruby script

Add this snippet to your gemspec file:

```ruby
s.files += Dir['man/man?/*.?']         # UNIX manpages
s.files += Dir['man/**/*.{html,css}']  # HTML manpages
s.add_development_dependency 'md2man', '~> 5.0'
```

Add this line to your Rakefile:

```ruby
require 'md2man/rakefile'
```

You now have a `rake md2man` task that builds manual pages from Markdown files
(with ".markdown", ".mkd", or ".md" extension) inside `man/man*/` directories.
There are also sub-tasks to build manual pages individually as [roff] or HTML.

If you're using Bundler, this task also hooks into Bundler's gem packaging
tasks and ensures that your manual pages are built for packaging into a gem:

```ruby
bundle exec rake build
gem spec pkg/*.gem | fgrep man/
```

## License

[Spare A Life]: https://sunaku.github.io/vegan-for-life.html
> Like my work? :+1:  Please [spare a life] today as thanks!
:cow::pig::chicken::fish::speak_no_evil::v::revolving_hearts:

Copyright 2011 Suraj N. Kurapati <https://github.com/sunaku>

Released under the ISC license.  See the LICENSE file for details.

[roff]: http://troff.org
[Redcarpet]: https://github.com/vmg/redcarpet
[Markdown]: http://daringfireball.net/projects/markdown/
[tables]: http://michelf.com/projects/php-markdown/extra/#table
