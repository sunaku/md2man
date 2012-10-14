require 'rake'

# build man pages before building ruby gem using bundler
%w[build install release].each {|t| task t => :md2man }

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

file 'man/index.html' => webs do |t|
  output = []
  dirs = webs.group_by {|web| web.pathmap('%d') }.each do |dir, dir_webs|
    subdir = dir.pathmap('%f')
    output << %{<h2 id="#{subdir}">#{subdir}</h2>}
    dir_webs.each do |web|
      title = web.pathmap('%n').sub(/\.(.+)$/, '(\1)')
      link = %{<a href="#{subdir}/#{web.pathmap('%f')}">#{title}</a>}
      info = File.read(web).scan(%r{<h2.*?>NAME</h2>(.+?)<h2}m).flatten.first.
             to_s.split(/\s+-\s+/, 2).last.to_s.gsub(/<.+?>/, '') # strip HTML
      output << "<dl><dt>#{link}</dt><dd>#{info}</dd></dl>"
    end
    File.open("#{dir}/index.html", 'w') do |f|
      f << %{<meta http-equiv="refresh" content="0;url=../index.html##{subdir}"/>}
    end
  end
  File.open(t.name, 'w') {|f| f.puts output }
end

mkds.zip(webs).each do |src, dst|
  render_file_task.call src, dst, lambda {|input|
    require 'md2man/html/engine'
    output = Md2Man::HTML::ENGINE.render(input)
    navbar = '<div class="manpath-navigation">' + [
      %{<a href="../index.html">#{dst.pathmap('%1d')}</a>},
      %{<a href="index.html">#{dst.pathmap('%-1d')}</a>},
      %{<a href="">#{dst.pathmap('%n')}</a>},
    ].join(' &rarr; ') + '</div>'
    [navbar, output, navbar].join('<hr/>')
  }
end
