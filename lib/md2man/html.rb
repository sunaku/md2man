require 'cgi'
require 'shellwords'
require 'md2man/document'

module Md2Man::HTML

  include Md2Man::Document

  #---------------------------------------------------------------------------
  # document-level processing
  #---------------------------------------------------------------------------

  def preprocess document
    @h1_seen = false
    @seen_count_by_id = Hash.new {|h,k| h[k] = 0 }
    super
  end

  #---------------------------------------------------------------------------
  # block-level processing
  #---------------------------------------------------------------------------

  def normal_paragraph text
    "<p>#{text}</p>"
  end

  def tagged_paragraph text
    head, *body = text.lines.to_a
    "<dl><dt>#{head.chomp}</dt><dd>#{body.join}</dd></dl>"
  end

  def indented_paragraph text
    "<dl><dd>#{text}</dd></dl>"
  end

  # see "Title line" in man-pages(7) or "Top-level headings" in md2man(5)
  HEADER_PARTS = %w[ title section date source manual ].freeze

  def header text, level, _=nil
    if level == 1 and not @h1_seen
      @h1_seen = true
      text = CGI.unescape_html(text) # unescape &quot; for Shellwords.split()
      text = Shellwords.split(text).zip(HEADER_PARTS).map do |value, part|
        part ? %{<span class="md2man-#{part}">#{value}</span>} : value
      end.compact.join(' ')
    end

    # decode here, since we will emit this heading below as raw HTML anyway
    text = decode_references(text)

    # strip all HTML tags, squeeze all non-word characters, and lowercase it
    id = text.gsub(/<.+?>/, '-').gsub(/\W+/, '-').gsub(/^-|-$/, '').downcase

    # make duplicate anchors unique by appending numerical suffixes to them
    count = @seen_count_by_id[id] += 1
    id += "-#{count - 1}" if count > 1

    [
      %{<h#{level} id="#{id}">},
        text,
        %{<a name="#{id}" href="##{id}" class="md2man-permalink" title="permalink"></a>},
      "</h#{level}>",
    ].join
  end

  SYNTAX_HIGHLIGHTER = Class.new do
    require 'rouge'
    require 'rouge/plugins/redcarpet'
    extend Rouge::Plugins::Redcarpet
  end

  def block_code code, language
    SYNTAX_HIGHLIGHTER.block_code super, language
  end

  #---------------------------------------------------------------------------
  # span-level processing
  #---------------------------------------------------------------------------

  def codespan code
    "<code>#{CGI.escape_html super}</code>"
  end

  def reference input_match, output_match
    if output_match.pre_match =~ /<[^>]*\z/
      input_match.to_s
    else
      url = reference_url(input_match[:page], input_match[:section])
      %{<a class="md2man-reference" href="#{url}">#{input_match}</a>}
    end + output_match[:addendum].to_s
  end

  # You can override this in a derived class to compute URLs as you like!
  def reference_url page, section
    "../man#{section}/#{page}.#{section}.html"
  end

end
