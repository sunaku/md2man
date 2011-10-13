require 'redcarpet'
require 'redcarpet/render_man'

module BinMan
  class Renderer < Redcarpet::Render::ManPage
    def normal_text text
      # XXX: workaround for https://github.com/tanoku/redcarpet/pull/65
      super text.to_s
    end
  end

  RENDERER = Redcarpet::Markdown.new(Renderer,
                                     #:tables => true,
                                     :autolink => true,
                                     #:superscript => true,
                                     :no_intra_emphasis => true,
                                     :fenced_code_blocks => true,
                                     :space_after_headers => true)
end
