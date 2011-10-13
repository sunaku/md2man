require 'redcarpet'
require 'redcarpet/render_man'

module BinMan
  class Renderer < Redcarpet::Render::ManPage
    def normal_text text
      text.gsub(/(?<=\W)-(?=\W)/, '\\-') if text
    end

    alias codespan double_emphasis

    def postprocess document
      # encode references to other man pages
      document.gsub(/(\w+)(\([1-9nol]\)\s*)/, "\n.BR \\1 \\2\n")
    end
  end

  RENDERER = Redcarpet::Markdown.new(Renderer,
                                     #:tables => true,
                                     :autolink => true,
                                     #:superscript => true,
                                     :no_intra_emphasis => true,
                                     :fenced_code_blocks => true,
                                     :space_after_headers => true)
end
