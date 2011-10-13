require 'redcarpet'
require 'redcarpet/render_man'

module BinMan
  class Renderer < Redcarpet::Render::ManPage
    def normal_text text
      text.gsub(/(?<=\W)-(?=\W)/, '\\-') if text
    end

    def paragraph(text)
      "\n.PP\n#{text}\n"
    end

    alias codespan double_emphasis

    def postprocess document
      document.
        # squeeze blank lines to prevent double-spaced output
        gsub(/^\n/, '').

        # make indented paragraphs occupy less space on screen:
        # roff will fit the second line of the paragraph along
        # side the first line if it has enough room to do so!
        gsub(/^  (?=\S)/, '').

        # paragraphs beginning with bold/italic are definitions
        gsub(/^\.PP(?=\n\\f)/, '.TP').

        # encode references to other man pages as "hyperlinks"
        gsub(/(\w+)(\([1-9nol]\)\s*)/, "\n.BR \\1 \\2\n")
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
