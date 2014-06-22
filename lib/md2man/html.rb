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
      text = HEADER_PARTS.zip(Shellwords.split(text)).map do |part, value|
        %{<span class="md2man-#{part}">#{value}</span>} if value
      end.compact.join(' ')
    end

    # strip all HTML tags, squeeze all non-word characters, and lowercase it
    id = text.gsub(/<.+?>/, '-').gsub(/\W+/, '-').gsub(/^-|-$/, '').downcase

    [
      %{<h#{level} id="#{id}">},
        text,
        %{<a name="#{id}" href="##{id}" class="md2man-permalink">},
        '</a>',
      "</h#{level}>",
    ].join
  end

  #---------------------------------------------------------------------------
  # span-level processing
  #---------------------------------------------------------------------------

  def reference input_match, output_match
    if output_match.pre_match =~ /<[^>]*\z/
      input_match.to_s
    else
      url = reference_url(input_match[:page], input_match[:section])
      %{<a class="md2man-xref" href="#{url}">#{input_match}</a>}
    end + output_match[:addendum].to_s
  end

  # You can override this in a derived class to compute URLs as you like!
  def reference_url page, section
    "../man#{section}/#{page}.#{section}.html"
  end

end
