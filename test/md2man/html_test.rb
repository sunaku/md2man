require 'test_helper'
require 'md2man/html/engine'

describe Md2Man::HTML do
  before do
    @markdown = Redcarpet::Markdown.new(
      Md2Man::HTML::Engine,
      :tables => true,
      :autolink => true,
    )
  end

  def heredoc document
    document.gsub(/^\s*\|/, '').chomp
  end

  it 'renders nothing as nothing' do
    @markdown.render('').must_be_empty
  end

  it 'renders paragraphs' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |just some paragraph
      |spanning
      |multiple
      |lines
      |but within 4-space indent
    INPUT
      |<p>just some paragraph
      |spanning
      |multiple
      |lines
      |but within 4-space indent</p>
    OUTPUT
  end

  it 'renders tagged paragraphs with uniformly two-space indented bodies' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |just some paragraph
      |  spanning
      |  multiple
      |  lines
      |  but within 4-space indent
      |
      |  and a single line following
      |
      |  and multiple
      |  lines following
    INPUT
      |<dl><dt>just some paragraph</dt><dd>spanning
      |multiple
      |lines
      |but within 4-space indent</dd></dl><dl><dd>and a single line following</dd></dl><dl><dd>and multiple
      |lines following</dd></dl>
    OUTPUT
  end

  it 'renders references to other man pages as hyperlinks' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |convert them from markdown(7) into roff(7), using
    INPUT
      |<p>convert them from <a href="markdown.7.html">markdown(7)</a> into <a href="roff.7.html">roff(7)</a>, using</p>
    OUTPUT
  end
end
