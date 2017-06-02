require 'md2man'
require 'rake/tasklib'

module Md2Man
  class Task < Rake::TaskLib

    attr_reader :markdown_files

    attr_reader :man_pages

    def initialize(options={})
      @options = options

      @markdown_files = Dir['man/*.{md,markdown}']
      @man_pages      = @markdown_files.map do |path|
        path.gsub(/\.(md|markdown)$/,'')
      end

      define
    end

    def define
      @man_pages.zip(@markdown_files).each do |man_page,markdown_file|
        # define file tasks for each man-page and markdown source file
        file(man_page => markdown_file) do
          File.open(man_page,'w') do |output|
            input = File.read(markdown_file)
            roff  = engine.render(input)

            output.write(roff)
          end
        end
      end

      namespace :man do
        desc "Renders man-pages from markdown files in man/"
        task :pages => @man_pages
      end
    end

    protected

    def engine
      @engine ||= Redcarpet::Markdown.new(Md2Man::Engine,@options)
    end

  end
end
