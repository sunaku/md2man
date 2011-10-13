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
    alias triple_emphasis double_emphasis

    def autolink link, link_type
      emphasis link
    end

    def link link, title, content
      "#{triple_emphasis content} #{emphasis link}"
    end

    DEFINITION_INDENT = '  ' # two spaces

    def postprocess document
      document.
        # squeeze blank lines to prevent double-spaced output
        gsub(/^\n/, '').

        # first paragraphs inside list items
        gsub(/^(\.IP.*)\n\.PP/, '\1').

        # paragraphs beginning with bold/italic and followed by
        # at least one definition-indented line are definitions
        gsub(/^\.PP(?=\n\\f.+\n#{DEFINITION_INDENT}\S)/, '.TP').

        # make indented paragraphs occupy less space on screen:
        # roff will fit the second line of the paragraph along
        # side the first line if it has enough room to do so!
        gsub(/^#{DEFINITION_INDENT}(?=\S)/, '').

        # encode references to other man pages as "hyperlinks"
        gsub(/(\w+)(\([1-9nol]\)[[:punct:]]?\s*)/, "\n.BR \\1 \\2\n").
        # keep the SEE ALSO sequence of references in-line
        gsub(/(?:^\.BR.+\n)+/m){ |sequence| sequence.squeeze("\n") }
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
