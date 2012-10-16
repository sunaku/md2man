require 'md2man/engine'

require 'rake/tasklib'

module Md2Man
  #---------------------------------------------------------------------------
  # Rake tasks for Md2Man
  #---------------------------------------------------------------------------
  class Tasks < Rake::TaskLib

    # Markdown file glob pattern
    FILES = 'man/**/*.{markdown,mkd,md}'

    # Default options for Md2Man
    OPTIONS = {
      :tables             => true,
      :autolink           => true,
      :superscript        => true,
      :strikethrough      => true,
      :no_intra_emphasis  => false,
      :fenced_code_blocks => true
    }

    # Options for Md2Man
    attr_reader :options

    # Initializes the md2man tasks.
    def initialize(options={})
      @options = OPTIONS.dup
      @options.merge!(options[:options]) if options[:options]

      @html = options.fetch(:html,true)

      @markdown_files = FileList[FILES]
      @man_page_files = @markdown_files.pathmap('%X')

      define
    end

    protected

    # Defines the md2man tasks.
    def define
      desc 'Build manual pages from Markdown files in man/'
      task :md2man => 'md2man:man'

      desc 'Build UNIX manual pages from Markdown files in man/'
      task 'md2man:man' => @man_page_files

      @markdown_files.zip(@man_page_files).each do |source,dest|
        render(source,dest) do |input|
          markdown_engine.render(input)
        end
      end

      define_html if @html
    end

    # Defines the md2man:html tasks.
    def define_html
      require 'md2man/html/engine'

      @html_files = @man_page_files.pathmap('%p.html')

      task :md2man => 'md2man:html'

      desc 'Build HTML manual pages from Markdown files in man/'
      task 'md2man:html' => 'man/index.html'

      file 'man/index.html' => @html_files do |t|
        output = []

        dirs = @html_files.group_by { |path| path.pathmap('%d') }.each do |dir, dir_htmls|
          subdir = dir.pathmap('%f')
          output << %{<h2 id="#{subdir}">#{subdir}</h2>}

          dir_htmls.each do |html|
            title = html.pathmap('%n').sub(/\.(.+)$/, '(\1)')
            link = %{<a href="#{subdir}/#{html.pathmap('%f')}">#{title}</a>}
            info = File.read(html).scan(%r{<h2.*?>NAME</h2>(.+?)<h2}m).flatten.first.
              to_s.split(/\s+-\s+/, 2).last.to_s.gsub(/<.+?>/, '') # strip HTML
            output << "<dl><dt>#{link}</dt><dd>#{info}</dd></dl>"
          end

          File.open("#{dir}/index.html", 'w') do |f|
            f << %{<meta http-equiv="refresh" content="0;url=../index.html##{subdir}"/>}
          end
        end

        File.open(t.name, 'w') { |f| f.puts output }
      end

      @markdown_files.zip(@html_files).each do |source, dest|
        render(source,dest) do |input|
          output = html_engine.render(input)
          navbar = '<div class="manpath-navigation">' + [
            %{<a href="../index.html">#{dest.pathmap('%1d')}</a>},
            %{<a href="index.html">#{dest.pathmap('%-1d')}</a>},
            %{<a href="">#{dest.pathmap('%n')}</a>},
          ].join(' &rarr; ') + '</div>'

          [navbar, output, navbar].join('<hr/>')
        end
      end
    end

    # The Md2Man markdown engine.
    def markdown_engine
      @markdown_engine ||= Redcarpet::Markdown.new(Md2Man::Engine,@options)
    end

    # The Md2Man HTML engine.
    def html_engine
      @html_engine ||= Redcarpet::Markdown.new(Md2Man::HTML::Engine,@options)
    end

    # Renders the dest file based on the source file.
    def render(source,dest)
      dest_dir = File.dirname(dest)

      directory dest_dir

      file(dest => [dest_dir, source]) do
        input  = File.read(source)
        output = yield(input)

        File.open(dest,'w') do |f|
          f << output
        end
      end
    end
  end
end
