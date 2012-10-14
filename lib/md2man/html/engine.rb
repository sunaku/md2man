require 'redcarpet'
require 'md2man/html'

module Md2Man::HTML

  class Engine < Redcarpet::Render::HTML
    include Md2Man::HTML
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
