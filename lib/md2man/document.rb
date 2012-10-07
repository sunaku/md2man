module Md2Man
module Document

  def preprocess document
    document
  end

  def postprocess document
    # encode references to other manual pages
    document.gsub(/(\S+)\(([1-9nol])\)([[:punct:]]?\s*)/){ reference $1,$2,$3 }
  end

  def reference page, section, addendum
    warn "md2man/document: reference not implemented: #{page}(#{section})"
  end

  PARAGRAPH_INDENT = /^\s*$|^  (?=\S)/

  def paragraph text
    head, *body = text.lines.to_a
    head_indented = head =~ PARAGRAPH_INDENT
    body_indented = !body.empty? && body.all? {|s| s =~ PARAGRAPH_INDENT }

    if head_indented || body_indented
      text = text.gsub(PARAGRAPH_INDENT, '')
      if head_indented && (body_indented || body.empty?)
        indented_paragraph text
      else
        tagged_paragraph text
      end
    else
      normal_paragraph text.chomp
    end
  end

  def indented_paragraph text
    warn "md2man/document: indented_paragraph not implemented: #{text.inspect}"
  end

  def tagged_paragraph text
    warn "md2man/document: tagged_paragraph not implemented: #{text.inspect}"
  end

  def normal_paragraph text
    warn "md2man/document: normal_paragraph not implemented: #{text.inspect}"
  end

end
end
