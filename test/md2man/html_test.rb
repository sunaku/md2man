require 'test_helper'
require 'md2man/html/engine'

describe 'html engine' do
  before do
    @markdown = Md2Man::HTML::ENGINE
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

  it 'does not break surrounding Markdown while processing references' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |For example, the `printf(3)` cross reference would be emitted as this HTML:
      |
      |    <a class="md2man-reference" href="../man3/printf.3.html">printf(3)</a>
    INPUT
      |<p>For example, the <code>printf(3)</code> cross reference would be emitted as this HTML:</p><div class="highlight"><pre class="highlight plaintext"><code>&lt;a class="md2man-reference" href="../man3/printf.3.html"&gt;printf(3)&lt;/a&gt;
      |</code></pre></div>
    OUTPUT
  end

  it 'renders references to other man pages as hyperlinks in middle of line' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |convert them from markdown(7) into roff(7), using
    INPUT
      |<p>convert them from <a class="md2man-reference" href="../man7/markdown.7.html">markdown(7)</a> into <a class="md2man-reference" href="../man7/roff.7.html">roff(7)</a>, using</p>
    OUTPUT
  end

  it 'renders references to other man pages as hyperlinks at beginning of line' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |markdown(1) into roff(2)
    INPUT
      |<p><a class="md2man-reference" href="../man1/markdown.1.html">markdown(1)</a> into <a class="md2man-reference" href="../man2/roff.2.html">roff(2)</a></p>
    OUTPUT
  end

  it 'does not render references inside code blocks' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    this is a code block
      |    containing markdown(7),
      |    roff(7), and much more!
    INPUT
      |<div class="highlight"><pre class="highlight plaintext"><code>this is a code block
      |containing markdown(7),
      |roff(7), and much more!
      |</code></pre></div>
    OUTPUT
  end

  it 'does not render references inside code spans' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |this is a code span `containing markdown(7), roff(7), and` much more!
    INPUT
      |<p>this is a code span <code>containing markdown(7), roff(7), and</code> much more!</p>
    OUTPUT
  end

  it 'does not render references inside image descriptions' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |![Obligatory screenshot of md2man-roff(1) in action!](
      |https://raw.github.com/sunaku/md2man/master/EXAMPLE.png)
    INPUT
      |<p><img src="https://raw.github.com/sunaku/md2man/master/EXAMPLE.png" alt="Obligatory screenshot of md2man-roff(1) in action!"></p>
    OUTPUT
  end

  it 'escapes backslashes inside code blocks' do
    # NOTE: we have to escape backslashes in the INPUT to
    #       prevent Ruby from interpreting them as escapes
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    _______      _______
      |     ___  /___________ /__
      |      _  __/ __ \\  __/ /_/
      |      / /_/ /_/ / / / ,\\
      |      \\__/\\____/_/ /_/|_\\
      |                 >>>------>
    INPUT
      |<div class="highlight"><pre class="highlight plaintext"><code>_______      _______
      | ___  /___________ /__
      |  _  __/ __ \\  __/ /_/
      |  / /_/ /_/ / / / ,\\
      |  \\__/\\____/_/ /_/|_\\
      |             &gt;&gt;&gt;------&gt;
      |</code></pre></div>
    OUTPUT
  end

  it 'decorates top-level headings components in spans with CSS classes' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |# title section date source manual
    INPUT
<h1 id="title-section-date-source-manual"><span class="md2man-title">title</span> <span class="md2man-section">section</span> <span class="md2man-date">date</span> <span class="md2man-source">source</span> <span class="md2man-manual">manual</span><a name="title-section-date-source-manual" href="#title-section-date-source-manual" class="md2man-permalink" title="permalink"></a></h1>
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |# FOO 1 "MARCH 1995" Linux "User Manuals"
    INPUT
<h1 id="foo-1-march-1995-linux-user-manuals"><span class="md2man-title">FOO</span> <span class="md2man-section">1</span> <span class="md2man-date">MARCH 1995</span> <span class="md2man-source">Linux</span> <span class="md2man-manual">User Manuals</span><a name="foo-1-march-1995-linux-user-manuals" href="#foo-1-march-1995-linux-user-manuals" class="md2man-permalink" title="permalink"></a></h1>
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |# title section date source
    INPUT
<h1 id="title-section-date-source"><span class="md2man-title">title</span> <span class="md2man-section">section</span> <span class="md2man-date">date</span> <span class="md2man-source">source</span><a name="title-section-date-source" href="#title-section-date-source" class="md2man-permalink" title="permalink"></a></h1>
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |# title section date
    INPUT
<h1 id="title-section-date"><span class="md2man-title">title</span> <span class="md2man-section">section</span> <span class="md2man-date">date</span><a name="title-section-date" href="#title-section-date" class="md2man-permalink" title="permalink"></a></h1>
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |# title section
    INPUT
<h1 id="title-section"><span class="md2man-title">title</span> <span class="md2man-section">section</span><a name="title-section" href="#title-section" class="md2man-permalink" title="permalink"></a></h1>
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |# title
    INPUT
<h1 id="title"><span class="md2man-title">title</span><a name="title" href="#title" class="md2man-permalink" title="permalink"></a></h1>
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |#
    INPUT
    OUTPUT
  end

  it 'preserves any extra components found in top-level headings' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |# title section date source manual extra! extra! read all about it!
    INPUT
<h1 id="title-section-date-source-manual-extra-extra-read-all-about-it"><span class="md2man-title">title</span> <span class="md2man-section">section</span> <span class="md2man-date">date</span> <span class="md2man-source">source</span> <span class="md2man-manual">manual</span> extra! extra! read all about it!<a name="title-section-date-source-manual-extra-extra-read-all-about-it" href="#title-section-date-source-manual-extra-extra-read-all-about-it" class="md2man-permalink" title="permalink"></a></h1>
    OUTPUT
  end

  it 'adds permalinks to headings' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |# foo *BAR*
      |## bar BAZ
      |### --BAZ-QUX--
      |#### qux (MOZ)
      |##### {m}oz END
      |# bar BAZ
      |## bar *BAZ*
      |### bar **BAZ**
      |#### -bar--BAZ---
    INPUT
<h1 id="foo-bar"><span class=\"md2man-title\">foo</span> <span class=\"md2man-section\"><em>BAR</em></span><a name="foo-bar" href="#foo-bar" class="md2man-permalink" title="permalink"></a></h1>\
<h2 id="bar-baz">bar BAZ<a name="bar-baz" href="#bar-baz" class="md2man-permalink" title="permalink"></a></h2>\
<h3 id="baz-qux">--BAZ-QUX--<a name="baz-qux" href="#baz-qux" class="md2man-permalink" title="permalink"></a></h3>\
<h4 id="qux-moz">qux (MOZ)<a name="qux-moz" href="#qux-moz" class="md2man-permalink" title="permalink"></a></h4>\
<h5 id="m-oz-end">{m}oz END<a name="m-oz-end" href="#m-oz-end" class="md2man-permalink" title="permalink"></a></h5>\
<h1 id="bar-baz-1">bar BAZ<a name="bar-baz-1" href="#bar-baz-1" class="md2man-permalink" title="permalink"></a></h1>\
<h2 id="bar-baz-2">bar <em>BAZ</em><a name="bar-baz-2" href="#bar-baz-2" class="md2man-permalink" title="permalink"></a></h2>\
<h3 id="bar-baz-3">bar <strong>BAZ</strong><a name="bar-baz-3" href="#bar-baz-3" class="md2man-permalink" title="permalink"></a></h3>\
<h4 id="bar-baz-4">-bar--BAZ---<a name="bar-baz-4" href="#bar-baz-4" class="md2man-permalink" title="permalink"></a></h4>
    OUTPUT
  end

  it 'adds permalinks to headings that contain man page references' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |## here is-a-reference(3) to another man page
      |
      |here is a paragraph containing is-a-reference(3) again
      |
      |here is another paragraph containing is-a-reference(3) yet again
    INPUT
<h2 id="here-is-a-reference-3-to-another-man-page">here <a class="md2man-reference" href="../man3/is-a-reference.3.html">is-a-reference(3)</a> to another man page<a name="here-is-a-reference-3-to-another-man-page" href="#here-is-a-reference-3-to-another-man-page" class="md2man-permalink" title="permalink"></a></h2>\
<p>here is a paragraph containing <a class="md2man-reference" href="../man3/is-a-reference.3.html">is-a-reference(3)</a> again</p>\
<p>here is another paragraph containing <a class="md2man-reference" href="../man3/is-a-reference.3.html">is-a-reference(3)</a> yet again</p>
    OUTPUT
  end

  it 'https://github.com/sunaku/md2man/issues/19' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |### Macros
      |
      |    #define PIPES_GET_LAST(CHAIN)
      |    #define PIPES_GET_IN(CHAIN)
      |    #define PIPES_GET_OUT(CHAIN)
      |    #define PIPES_GET_ERR(CHAIN)
      |
      |### `PIPES_GET_LAST(CHAIN)`
    INPUT
      |<h3 id="macros">Macros<a name="macros" href="#macros" class="md2man-permalink" title="permalink"></a></h3><div class="highlight"><pre class="highlight plaintext"><code>#define PIPES_GET_LAST(CHAIN)
      |#define PIPES_GET_IN(CHAIN)
      |#define PIPES_GET_OUT(CHAIN)
      |#define PIPES_GET_ERR(CHAIN)
      |</code></pre></div><h3 id="pipes_get_last-chain"><code>PIPES_GET_LAST(CHAIN)</code><a name="pipes_get_last-chain" href="#pipes_get_last-chain" class="md2man-permalink" title="permalink"></a></h3>
    OUTPUT
  end

  it 'supports sole space or tab in codespans' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |`\s`
    INPUT
      |<p><code>\s</code></p>
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |`\t`
    INPUT
      |<p><code>\s</code></p>
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |`\n`
    INPUT
      |<p><code>\n</code></p>
    OUTPUT
  end

  it 'renders fenced code blocks' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |```
      | Array.new(123, "abc")
      |```
    INPUT
      |<div class="highlight"><pre class="highlight plaintext"><code> Array.new(123, "abc")
      |</code></pre></div>
    OUTPUT
  end

  it 'renders fenced code blocks with syntax highlighting' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |```ruby
      | Array.new(123, "abc")
      |```
    INPUT
      |<div class="highlight"><pre class="highlight ruby"><code> <span class="no">Array</span><span class="p">.</span><span class="nf">new</span><span class="p">(</span><span class="mi">123</span><span class="p">,</span> <span class="s2">"abc"</span><span class="p">)</span>
      |</code></pre></div>
    OUTPUT
  end
end
