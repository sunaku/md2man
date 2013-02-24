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
</head>
<body>#{content}</body>
</html>
WRAP_HTML_TEMPLATE
end

parse_manpage_name = lambda do |html_file_name|
  html_file_name.pathmap('%n').sub(/\.(.+)$/, '(\1)')
end

parse_manpage_info = lambda do |html_file_body|
  html_file_body.scan(%r{<h2.*?>NAME</h2>(.+?)<h2}m).flatten.first.
  to_s.split(/\s+-\s+/, 2).last.to_s.gsub(/<.+?>/, '') # strip HTML
end

file 'man/index.html' => webs do |t|
  buffer = []
  webs.group_by {|web| web.pathmap('%d') }.each do |dir, dir_webs|
    subdir = dir.sub('man/', '')
    buffer << %{<h2 id="#{subdir}">#{subdir}</h2>}

    dir_webs.each do |web|
      name = parse_manpage_name.call(web)
      info = parse_manpage_info.call(File.read(web))
      link = %{<a href="#{subdir}/#{web.pathmap('%f')}">#{name}</a>}
      buffer << "<dl><dt>#{link}</dt><dd>#{info}</dd></dl>"
    end
  end

  title = t.name.pathmap('%X')
  content = buffer.join(?\n)
  output = wrap_html_template.call(title, content)

  File.open(t.name, 'w') {|f| f << output }
end

mkds.zip(webs).each do |src, dst|
  render_file_task.call src, dst, lambda {|input|
    require 'md2man/html/engine'
    output = Md2Man::HTML::ENGINE.render(input)

    name = parse_manpage_name.call(dst)
    info = parse_manpage_info.call(output)
    title = [name, info].join(' &mdash; ')

    subdir = dst.pathmap('%d').sub('man/', '')
    ascend = '../' * subdir.count('/').next
    navbar = [
      '<div class="manpath-navigation">',
        %{<a href="#{ascend}index.html##{subdir}">#{subdir}</a>},
        ' &rarr; ',
        %{<a href="">#{name}</a>},
      '</div>',
    ].join

    content = [navbar, output, navbar].join('<hr/>')
    wrap_html_template.call title, content
  }
end
