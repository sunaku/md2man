require 'redcarpet'
require 'md2man/html'

module Md2Man
module HTML

  class Engine < Redcarpet::Render::HTML
    include HTML
  end

  ENGINE = Redcarpet::Markdown.new(Engine,
    :tables => true,
    :autolink => true,
    :superscript => true,
    :strikethrough => true,
    :no_intra_emphasis => false,
    :fenced_code_blocks => true
  )

end
end
