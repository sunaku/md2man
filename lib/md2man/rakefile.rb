require 'rake'

# build man pages before building ruby gem using bundler
if defined? Bundler::GemHelper
  %w[build install release].each {|t| task t => :md2man }
end

#-----------------------------------------------------------------------------
desc 'Build manual pages from Markdown files in man/.'
task :md2man => ['md2man:man', 'md2man:web']
#-----------------------------------------------------------------------------

mkds = FileList['man/**/*.{markdown,mkd,md}']
mans = mkds.pathmap('%X')
webs = mans.pathmap('%p.html')

render_file_task = lambda do |src, dst, renderer|
  directory dir = dst.pathmap('%d')
  file dst => [dir, src] do
    input = File.read(src)
    output = renderer.call(input)
    File.open(dst, 'w') {|f| f << output }
  end
end

#-----------------------------------------------------------------------------
desc 'Build UNIX manual pages from Markdown files in man/.'
task 'md2man:man' => mans
#-----------------------------------------------------------------------------

mkds.zip(mans).each do |src, dst|
  render_file_task.call src, dst, lambda {|input|
    require 'md2man/engine'
    Md2Man::ENGINE.render(input)
  }
end

#-----------------------------------------------------------------------------
desc 'Build HTML manual pages from Markdown files in man/.'
task 'md2man:web' => 'man/index.html'
#-----------------------------------------------------------------------------

wrap_html_template = lambda do |title, content|
<<WRAP_HTML_TEMPLATE
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>#{title}</title>
  <!--[if lt IE 9]><script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script><![endif]-->
  <link rel="stylesheet" href="http://twitter.github.com/bootstrap/assets/css/bootstrap.css" />
  <style type="text/css">
    @media all {
      .manpage h1 {
        font-weight: normal;
        font-size: smaller;
        text-align: right;
      }
      .manpage h2,
      .manpage h3,
      .manpage h4,
      .manpage h5,
      .manpage h6 {
        margin-top: 1em;
      }

      /* deactivate external manual page cross-references */
      a.manpage-reference:not([href]) {
        color: inherit;
        text-decoration: none;
      }
    }
    @media screen {
      .manpage {
        font-family: monospace;
        max-width: 78ex;
      }
      .manpage h1 {
        margin-top: -5em;
      }
    }

    @media print {
      .navbar {
        display: none;
      }

      /* improve readability of revealed hyperlink URLs */
      a:after {
        font-family: monospace;
      }

      /* internal links and manual page cross-references */
      a[href^='#'], a[href^='../man'] {
        color: inherit;
        font-weight: bolder;
        text-decoration: none;
      }

      /* undo bootstrap's revealing of those hyperlinks */
      a[href^='#']:after, a[href^='../man']:after {
        content: none;
      }
    }
  </style>
</head>
<body>#{content}</body>
</html>
WRAP_HTML_TEMPLATE
end

parse_manpage_name = lambda do |html_file_name|
  html_file_name.pathmap('%n').sub(/\.(.+)$/, '(\1)')
end

parse_manpage_info = lambda do |html_file_body|
  if html_file_body =~ %r{<h2.*?>NAME</h2>(.+?)<h2}m
    $1.split(/\s+-\s+/, 2).last.gsub(/<.+?>/, '') # strip HTML
  end
end

file 'man/index.html' => webs do |t|
  buffer = ['<div class="container-fluid">']
  webs.group_by {|web| web.pathmap('%d') }.each do |dir, dir_webs|
    subdir = dir.sub('man/', '')
    buffer << %{<h2 id="#{subdir}">#{subdir}</h2>}

    dir_webs.each do |web|
      name = parse_manpage_name.call(web)
      info = parse_manpage_info.call(File.read(web))
      link = %{<a href="#{subdir}/#{web.pathmap('%f')}">#{name}</a>}
      buffer << %{<dl class="dl-horizontal"><dt>#{link}</dt><dd>#{info}</dd></dl>}
    end
  end
  buffer << '</div>'
  content = buffer.join

  title = t.name.pathmap('%X')
  output = wrap_html_template.call(title, content)
  File.open(t.name, 'w') {|f| f << output }
end

mkds.zip(webs).each do |src, dst|
  render_file_task.call src, dst, lambda {|input|
    require 'md2man/html/engine'
    output = Md2Man::HTML::ENGINE.render(input).
      # deactivate external manual page cross-references
      gsub(/(?<=<a class="manpage-reference") href="\.\.(.+?)"/) do
        $& if webs.include? 'man' + $1
      end

    name = parse_manpage_name.call(dst)
    info = parse_manpage_info.call(output)
    title = [name, info].compact.join(' &mdash; ')

    subdir = dst.pathmap('%d').sub('man/', '')
    ascend = '../' * subdir.count('/').next
    content = [
      '<div class="navbar">',
        '<div class="navbar-inner">',
          '<span class="brand">',
            %{<a href="#{ascend}index.html##{subdir}">#{subdir}</a>},
            '/',
            dst.pathmap('%n'),
          '</span>',
        '</div>',
      '</div>',
      '<div class="container-fluid">',
        '<div class="manpage">',
          output,
        '</div>',
      '</div>',
    ].join

    wrap_html_template.call title, content
  }
end
