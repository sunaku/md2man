require 'rake'

mkds = FileList['man/man*/*.{markdown,mkd,md}']
mans = mkds.pathmap('%X')
webs = mans.pathmap('%p.html')

desc 'Build manual pages from Markdown files in man/.'
task :md2man => ['md2man:man', 'md2man:web']

define_render_task = lambda do |src, dst, render|
  directory dir = dst.pathmap('%d')
  file dst => [dir, src] do
    input = File.read(src)
    output = render.call(input)
    File.open(dst, 'w') {|f| f << output }
  end
end

desc 'Build UNIX manual pages from Markdown files in man/.'
task 'md2man:man' => mans

mkds.zip(mans).each do |src, dst|
  define_render_task.call src, dst, lambda {|input|
    require 'md2man/engine'
    Md2Man::ENGINE.render(input)
  }
end

desc 'Build HTML manual pages from Markdown files in man/.'
task 'md2man:web' => webs

mkds.zip(webs).each do |src, dst|
  define_render_task.call src, dst, lambda {|input|
    require 'md2man/html/engine'
    Md2Man::HTML::ENGINE.render(input)
  }
end

# build man pages before building ruby gem using bundler
%w[build install release].each {|t| task t => :md2man }
