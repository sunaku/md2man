module Md2Man
module Document

  def preprocess document
    @references = {}
    encode_references document
  end

  def postprocess document
    decode_references document
  end

  def block_code code, language
    decode_references code, true
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

  def codespan code
    decode_references code, true
  end

protected

  def encode object
    "\0#{object.object_id}\0"
  end

private

  def encode_references text
    text.gsub(/(\S+)\(([1-9nol])\)([[:punct:]]?[^\n\S]*)/) do
      match = $~
      key = encode(match)
      @references[key] = match
      key
    end
  end

  def decode_references text, verbatim=false
    @references.select do |key, match|
      replacement = verbatim ? match.to_s : reference(*match.captures)
      text.sub! key, replacement
    end.each_key {|key| @references.delete key }
    text
  end

end
end
