require 'redcarpet'
require 'md2man/roff'

module Md2Man
  class Engine < Redcarpet::Render::Base
    include Roff
  end

  ENGINE = Redcarpet::Markdown.new(
    Md2Man::Engine,
    :tables => true,
    :autolink => true,
    :superscript => true,
    :strikethrough => true,
    :no_intra_emphasis => true,
    :fenced_code_blocks => true
  )
end
