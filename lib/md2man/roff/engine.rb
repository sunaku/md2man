require 'redcarpet'
require 'md2man/roff'

module Md2Man::Roff

  class Engine < Redcarpet::Render::Base
    include Md2Man::Roff
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
