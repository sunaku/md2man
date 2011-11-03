require 'redcarpet'

module RedcarpetManpage

  class Renderer < Redcarpet::Render::Base
    def normal_text(text)
      text.gsub(/(?<=\W)-(?=\W)/, '\\-') if text
    end

    def triple_emphasis(text)
      "\\fB#{text}\\fP"
    end

    alias double_emphasis triple_emphasis

    def emphasis(text)
      "\\fI#{text}\\fP"
    end

    def block_code(code, language)
      paragraph("\n.nf\n#{normal_text(code)}\n.fi\n")
    end

    alias codespan double_emphasis

    def link(link, title, content)
      "#{triple_emphasis(content)} #{emphasis(link)}"
    end

    def autolink(link, link_type)
      emphasis(link)
    end

    def header(title, level)
      case level
      when 1
        "\n.TH #{title}\n"

      when 2
        "\n.SH #{title}\n"

      when 3
        "\n.SS #{title}\n"
      end
    end

    def paragraph(text)
      "\n.PP\n#{text}\n"
    end

    def linebreak
      "\n.LP\n"
    end

    def list(content, list_type)
      case list_type
      when :ordered
        "\n\n.nr step 0 1\n#{content}\n"
      when :unordered
        "\n.\n#{content}\n"
      end
    end

    def list_item(content, list_type)
      case list_type
      when :ordered
        ".IP \\n+[step]\n#{content.strip}\n"
      when :unordered
        ".IP \\[bu] 2 \n#{content.strip}\n"
      end
    end

    DEFINITION_INDENT = '  ' # two spaces

    def postprocess document
      document.
        # squeeze blank lines to prevent double-spaced output
        gsub(/^\n/, '').

        # first paragraphs inside list items
        gsub(/^(\.IP.*)\n\.PP/, '\1').

        # paragraphs beginning with bold/italic and followed by
        # a definition-indented line are considered definitions
        gsub(/^\.PP(?=\n\\f.+\n#{DEFINITION_INDENT}\S)/, '.TP').

        # paragraphs beginning with a definition-indented line
        # are considered a part of multi-paragraph definitions
        gsub(/^\.PP(?=\n#{DEFINITION_INDENT}\S)/, '.IP').

        # make indented paragraphs occupy less space on screen:
        # roff will fit the second line of the paragraph along
        # side the first line if it has enough room to do so!
        gsub(/^#{DEFINITION_INDENT}(?=\S)/, '').

        # encode references to other man pages as "hyperlinks"
        gsub(/(\S+)(\([1-9nol]\)[[:punct:]]?\s*)/, "\n.BR \\1 \\2\n").
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
