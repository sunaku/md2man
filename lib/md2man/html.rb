require 'cgi'
require 'md2man/document'

module Md2Man::HTML

  include Md2Man::Document

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

  def header text, level
    id = text.gsub(/<.+?>/, '-').        # strip all HTML tags
      gsub(/\W+/, '-').gsub(/^-|-$/, '') # fold non-word chars
    %{<h#{level} id="#{id}">#{text}</h#{level}>}
  end

  #---------------------------------------------------------------------------
  # span-level processing
  #---------------------------------------------------------------------------

  def reference input_match, output_match
    if output_match.pre_match =~ /<[^>]*\z/
      input_match.to_s
    else
      url = reference_url(input_match[:page], input_match[:section])
      %{<a class="manpage-reference" href="#{url}">#{input_match}</a>}
    end + output_match[:addendum].to_s
  end

  # You can override this in a derived class to compute URLs as you like!
  def reference_url page, section
    "../man#{section}/#{page}.#{section}.html"
  end

end
