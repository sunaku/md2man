module Md2Man
module Document

  def postprocess document
    # encode references to other manual pages
    document.gsub(/(\S+)\(([1-9nol])\)([[:punct:]]?\s*)/){ reference $1,$2,$3 }
  end

  def reference page, section, addendum
    warn "md2man/document: reference not implemented: #{page}(#{section})"
  end

end
end
