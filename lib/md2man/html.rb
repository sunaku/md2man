require 'md2man/document'

module Md2Man
module HTML

  include Document

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

  #---------------------------------------------------------------------------
  # span-level processing
  #---------------------------------------------------------------------------

  def reference page, section, addendum
    url = reference_url(page, section)
    "<a href=#{url.inspect}>#{page}(#{section})</a>#{addendum}"
  end

  # You can override this in a derived class to compute URLs as you like!
  def reference_url page, section
    "#{page}.#{section}.html"
  end

end
end
