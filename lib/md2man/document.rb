require 'md2man'

module Md2Man::Document

  #---------------------------------------------------------------------------
  # document-level processing
  #---------------------------------------------------------------------------

  def preprocess document
    @references = {}
    encode_references document
  end

  def postprocess document
    decode_references document
  end

  #---------------------------------------------------------------------------
  # block-level processing
  #---------------------------------------------------------------------------

  PARAGRAPH_INDENT = /^\s*$|^  (?=\S)/

  # This method blocks Redcarpet's default behavior, which cannot be accessed
  # using super() due to the limitation of how Redcarpet is implemented in C.
  # See https://github.com/vmg/redcarpet/issues/51 for the complete details.
  #
  # We don't call super() here deliberately: to replace paragraph nodes with
  # normal_paragraph, tagged_paragraph, or indented_paragraph as appropriate.
  #
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

  def block_code code, language
    decode_references code, true
  end

  #---------------------------------------------------------------------------
  # span-level processing
  #---------------------------------------------------------------------------

  def codespan code
    decode_references (code || ' '), true
  end

  def reference input_match, output_match
    warn "md2man/document: reference not implemented: #{input_match}"
  end

protected

  def encode object
    "\0#{object.object_id}\0"
  end

private

  def encode_references text
    text.gsub(/(?<page>[\w\-\.]+)\((?<section>\w+)\)/) do
      match = $~
      key = encode(match)
      @references[key] = match
      key
    end
  end

  def decode_references text, restore_original=false
    @references.delete_if do |key, input_match|
      # the [^\S\n] captures all non-newline whitespace
      # basically, it's meant to be \s but excluding \n
      text.sub! /#{Regexp.escape key}(?<addendum>\S*[^\S\n]*)/ do
        output_match = $~
        if restore_original
          input_match.to_s + output_match[:addendum]
        else
          reference input_match, output_match
        end
      end
    end
    text
  end

end
