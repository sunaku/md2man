# http://www.linuxjournal.com/article/1158
# http://www.premvet.co.uk/premvet/faq/roff.html
# http://www.linuxhowtos.org/System/creatingman.htm
# http://www.fnal.gov/docs/products/ups/ReferenceManual/html/manpages.html
# http://serverfault.com/questions/109490/how-do-i-write-man-pages
# man groff_man
# man 7 groff

require 'test_helper'
require 'md2man/roff/engine'

describe 'roff engine' do
  before do
    @markdown = Md2Man::Roff::ENGINE
  end

  SPACE = 0x20.chr

  def heredoc document
    document.gsub(/^\s*\|/, '')
  end

  it 'renders nothing as nothing' do
    @markdown.render('').must_be_empty
  end

  it 'strips leading newlines' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |
      |
      |two leading newlines
    INPUT
      |.PP
      |two leading newlines
    OUTPUT
  end

  it 'strips leading newlines but not leading spaces' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |
      |
      | two leading newlines followed by one space
    INPUT
      |.PP
      | two leading newlines followed by one space
    OUTPUT
  end

  it 'renders paragraphs' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |just some paragraph
      |spanning
      |multiple
      |lines
      |but within 4-space indent
    INPUT
      |.PP
      |just some paragraph
      |spanning
      |multiple
      |lines
      |but within 4\\-space indent
    OUTPUT
  end

  it 'renders paragraphs with unevenly indented bodies' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |just some paragraph
      | spanning
      |  multiple
      |   lines
      |but within 4-space indent
    INPUT
      |.PP
      |just some paragraph
      | spanning
      |  multiple
      |   lines
      |but within 4\\-space indent
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
      |.TP
      |just some paragraph
      |spanning
      |multiple
      |lines
      |but within 4\\-space indent
      |.IP
      |and a single line following
      |.IP
      |and multiple
      |lines following
    OUTPUT
  end

  it 'renders indented paragraphs that are uniformly two-space indented' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |  just some paragraph
      |  spanning
      |  multiple
      |  lines
      |  but within 4-space indent
    INPUT
      |.IP
      |just some paragraph
      |spanning
      |multiple
      |lines
      |but within 4\\-space indent
    OUTPUT
  end

  it 'renders tagged, indented, and normal paragraphs' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |This is a
      |normal paragraph.
      |
      |This is a
      |  tagged paragraph.
      |
      |  This is another
      |tagged paragraph.
      |
      |  This is an
      |  indented
      |  paragraph.
      |
      |This
      | is another
      |  normal
      |   paragraph.
    INPUT
      |.PP
      |This is a
      |normal paragraph.
      |.TP
      |This is a
      |tagged paragraph.
      |.TP
      |This is another
      |tagged paragraph.
      |.IP
      |This is an
      |indented
      |paragraph.
      |.PP
      |This
      | is another
      |  normal
      |   paragraph.
    OUTPUT
  end

  it 'escapes backslashes in normal text' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |c:\\drive
    INPUT
      |.PP
      |c:\\[rs]drive
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |c:\\drive\\walk\\\\\\car
    INPUT
      |.PP
      |c:\\[rs]drive\\[rs]walk\\[rs]\\[rs]car
    OUTPUT
  end

  it 'escapes hyphens in normal text' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |pre-process
    INPUT
      |.PP
      |pre\\-process
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |1-5
    INPUT
      |.PP
      |1\\-5
    OUTPUT
  end

  it 'escapes periods at the beginning of lines in normal text' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |.
    INPUT
      |.PP
      |\\&.
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |..
    INPUT
      |.PP
      |\\&..
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |...
    INPUT
      |.PP
      |\\&...
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |.hello. world qu.o.tes
    INPUT
      |.PP
      |\\&.hello. world qu.o.tes
    OUTPUT
  end

  it 'escapes single quotes at the beginning of lines in normal text' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |'
    INPUT
      |.PP
      |\\&'
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |''
    INPUT
      |.PP
      |\\&''
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |'''
    INPUT
      |.PP
      |\\&'''
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |'hello' world qu'o'tes
    INPUT
      |.PP
      |\\&'hello' world qu'o'tes
    OUTPUT
  end

  it 'escapes periods at the beginning of lines in code blocks' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    .
    INPUT
      |.PP
      |.RS
      |.nf
      |\\&.
      |.fi
      |.RE
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    ..
    INPUT
      |.PP
      |.RS
      |.nf
      |\\&..
      |.fi
      |.RE
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    ...
    INPUT
      |.PP
      |.RS
      |.nf
      |\\&...
      |.fi
      |.RE
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    .hello. world qu.o.tes
    INPUT
      |.PP
      |.RS
      |.nf
      |\\&.hello. world qu.o.tes
      |.fi
      |.RE
    OUTPUT
  end

  it 'escapes single quotes at the beginning of lines in code blocks' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    '
    INPUT
      |.PP
      |.RS
      |.nf
      |\\&'
      |.fi
      |.RE
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    ''
    INPUT
      |.PP
      |.RS
      |.nf
      |\\&''
      |.fi
      |.RE
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    '''
    INPUT
      |.PP
      |.RS
      |.nf
      |\\&'''
      |.fi
      |.RE
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    'hello' world qu'o'tes
    INPUT
      |.PP
      |.RS
      |.nf
      |\\&'hello' world qu'o'tes
      |.fi
      |.RE
    OUTPUT
  end

  it 'renders emphasis' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |just *some paragraph*
      | sp*ann*ing
      |  multiple
      |   *lines*
      |but within 4-*space* indent
    INPUT
      |.PP
      |just \\fIsome paragraph\\fP
      | sp\\fIann\\fPing
      |  multiple
      |   \\fIlines\\fP
      |but within 4\\-\\fIspace\\fP indent
    OUTPUT
  end

  it 'renders double emphasis' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |just **some paragraph**
      | sp**ann**ing
      |  multiple
      |   **lines**
      |but within 4-**space** indent
    INPUT
      |.PP
      |just \\fBsome paragraph\\fP
      | sp\\fBann\\fPing
      |  multiple
      |   \\fBlines\\fP
      |but within 4\\-\\fBspace\\fP indent
    OUTPUT
  end

  it 'renders triple emphasis' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |just ***some paragraph***
      | sp***ann***ing
      |  multiple
      |   ***lines***
      |but within 4-***space*** indent
    INPUT
      |.PP
      |just \\s+2\\fBsome paragraph\\fP\\s-2
      | sp\\s+2\\fBann\\fP\\s-2ing
      |  multiple
      |   \\s+2\\fBlines\\fP\\s-2
      |but within 4\\-\\s+2\\fBspace\\fP\\s-2 indent
    OUTPUT
  end

  it 'renders top-level headings' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |just some h1 heading
      |====================
    INPUT
      |.TH just some h1 heading
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |BINMAN 1 "2011-11-05" "1.1.0" "Ruby User Manuals"
      |=================================================
    INPUT
      |.TH BINMAN 1 "2011\\-11\\-05" "1.1.0" "Ruby User Manuals"
    OUTPUT
  end

  it 'renders non-first top-level headings as 2nd-level headings' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |just some h1 heading
      |====================
      |
      |yet another h1 heading
      |======================
    INPUT
      |.TH just some h1 heading
      |.SH yet another h1 heading
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |BINMAN 1 "2011-11-05" "1.1.0" "Ruby User Manuals"
      |=================================================
      |
      |DUPMAN 1 "2011-11-05" "1.1.0" "Ruby User Manuals"
      |=================================================
    INPUT
      |.TH BINMAN 1 "2011\\-11\\-05" "1.1.0" "Ruby User Manuals"
      |.SH DUPMAN 1 "2011\\-11\\-05" "1.1.0" "Ruby User Manuals"
    OUTPUT
  end

  it 'renders 2nd-level headings' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |just some h2 heading
      |--------------------
    INPUT
      |.SH just some h2 heading
    OUTPUT
  end

  it 'renders level 3..6 headings' do
    (3..6).each do |level|
      @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
        |#{'#' * level} just some subheading
      INPUT
        |.SS just some subheading
      OUTPUT
    end
  end

  it 'renders linebreaks (2 spaces at EOL)' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |line#{SPACE}#{SPACE}
      |break
    INPUT
      |.PP
      |line
      |.br
      |break
    OUTPUT
  end

  it 'renders blockquotes' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |>just some paragraph
      |> spanning
      |>  multiple
      |>   lines
      |>but within 4-space indent
    INPUT
      |.PP
      |.RS
      |just some paragraph
      |spanning
      | multiple
      |  lines
      |but within 4\\-space indent
      |.RE
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |some paragraph above
      |
      |>just some paragraph
      |> spanning
      |>  multiple
      |>   lines
      |>but within 4-space indent
    INPUT
      |.PP
      |some paragraph above
      |.PP
      |.RS
      |just some paragraph
      |spanning
      | multiple
      |  lines
      |but within 4\\-space indent
      |.RE
    OUTPUT
  end

  it 'renders code blocks' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    single preformatted line
    INPUT
      |.PP
      |.RS
      |.nf
      |single preformatted line
      |.fi
      |.RE
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    just some *paragraph*
      |     spanning
      |      **multiple**
      |    >  lines
      |    with 4-space indent
    INPUT
      |.PP
      |.RS
      |.nf
      |just some *paragraph*
      | spanning
      |  **multiple**
      |>  lines
      |with 4\\-space indent
      |.fi
      |.RE
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    just some *paragraph*
      |
      |     spanning
      |
      |
      |      **multiple**
      |
      |    >  lines
      |    with 4-space indent
      |
      |
      |    and blank lines within
    INPUT
      |.PP
      |.RS
      |.nf
      |just some *paragraph*
      |
      | spanning
      |
      |
      |  **multiple**
      |
      |>  lines
      |with 4\\-space indent
      |
      |
      |and blank lines within
      |.fi
      |.RE
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |normal paragraph line
      |
      |    single preformatted line
    INPUT
      |.PP
      |normal paragraph line
      |.PP
      |.RS
      |.nf
      |single preformatted line
      |.fi
      |.RE
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
      |.PP
      |.RS
      |.nf
      |_______      _______
      | ___  /___________ /__
      |  _  __/ __ \\\\  __/ /_/
      |  / /_/ /_/ / / / ,\\\\
      |  \\\\__/\\\\____/_/ /_/|_\\\\
      |             >>>\\-\\-\\-\\-\\-\\->
      |.fi
      |.RE
    OUTPUT
  end

  it 'renders code spans' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |here is `some code` for you
    INPUT
      |.PP
      |here is \\fB\\fCsome code\\fR for you
    OUTPUT
  end

  it 'escapes backslashes inside code spans' do
    # NOTE: we have to escape backslashes in the INPUT to
    #       prevent Ruby from interpreting them as escapes
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |here is `so\\m\\e \\c\\ode` for you
    INPUT
      |.PP
      |here is \\fB\\fCso\\\\m\\\\e \\\\c\\\\ode\\fR for you
    OUTPUT
  end

  it 'renders hyperlinks' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |Send [me](mailto:foo@bar.baz), e-mail.
    INPUT
      |.PP
      |Send me \\[la]foo@bar.baz\\[ra], e\\-mail.
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |Take [me](http://myself), somewhere.
    INPUT
      |.PP
      |Take me \\[la]http://myself\\[ra], somewhere.
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |Mail me foo@bar.baz now.
    INPUT
      |.PP
      |Mail me \\[la]foo@bar.baz\\[ra] now.
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |Take me http://www.somewhere now.
    INPUT
      |.PP
      |Take me \\[la]http://www.somewhere\\[ra] now.
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |Leave me
      |http://www.somewhere now.
    INPUT
      |.PP
      |Leave me
      |\\[la]http://www.somewhere\\[ra] now.
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |Tagged
      |  paragraph http://www.should.work correctly.
    INPUT
      |.TP
      |Tagged
      |paragraph \\[la]http://www.should.work\\[ra] correctly.
    OUTPUT
  end

  it 'renders unordered lists' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |Here is an unordered list:
      |
      |* foo
      |    * bar
      |        * baz
      |* qux
    INPUT
      |.PP
      |Here is an unordered list:
      |.RS
      |.IP \\(bu 2
      |foo
      |.RS
      |.IP \\(bu 2
      |bar
      |.RS
      |.IP \\(bu 2
      |baz
      |.RE
      |.RE
      |.IP \\(bu 2
      |qux
      |.RE
    OUTPUT
  end

  it 'renders unordered lists while squashing first paragraphs' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |Here is an unordered list:
      |
      |  * here is a
      |    paragraph
      |
      |    here is a
      |    subparagraph
    INPUT
      |.PP
      |Here is an unordered list:
      |.RS
      |.IP \\(bu 2
      |here is a
      |paragraph
      |.PP
      |here is a
      |subparagraph
      |.RE
    OUTPUT
  end

  it 'renders ordered lists' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |Here is an ordered list:
      |
      |1.  foo1
      |2.  foo2
      |    1.  bar
      |        1.  baz
      |3.  qux
    INPUT
      |.PP
      |Here is an ordered list:
      |.nr step2 0 1
      |.RS
      |.IP \\n+[step2]
      |foo1
      |.IP \\n+[step2]
      |foo2
      |.nr step1 0 1
      |.RS
      |.IP \\n+[step1]
      |bar
      |.nr step0 0 1
      |.RS
      |.IP \\n+[step0]
      |baz
      |.RE
      |.RE
      |.IP \\n+[step2]
      |qux
      |.RE
    OUTPUT
  end

  it 'renders ordered lists while squashing first paragraphs' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |Here is an ordered list:
      |
      |1.  here is a
      |    paragraph
      |
      |    here is a
      |    subparagraph
    INPUT
      |.PP
      |Here is an ordered list:
      |.nr step0 0 1
      |.RS
      |.IP \\n+[step0]
      |here is a
      |paragraph
      |.PP
      |here is a
      |subparagraph
      |.RE
    OUTPUT
  end

  it 'renders horizontal rules' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |foo
      |
      |* * *
      |
      |bar
    INPUT
      |.PP
      |foo
      |.ti 0
      |\\l'\\n(.lu'
      |.PP
      |bar
    OUTPUT
  end

  it 'renders horizontal rules inside blockquotes' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |>foo
      |>
      |>* * *
      |>
      |>bar
    INPUT
      |.PP
      |.RS
      |foo
      |.ti 0
      |\\l'\\n(.lu'
      |.PP
      |bar
      |.RE
    OUTPUT
  end

  it 'renders some named entities' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |&middot; &#183;
      |&copy; &#169;
      |&cent; &#162;
      |&Dagger; &#8225;
      |&deg; &#176;
      |&dagger; &#8224;
      |&quot; &#34;
      |&mdash; &#8212;
      |&ndash; &#8211;
      |&reg; &#174;
      |&sect; &#167;
      |&oline; &#8254;
      |&equiv; &#8801;
      |&ge; &#8805;
      |&le; &#8804;
      |&ne; &#8800;
      |&rarr; &#8594;
      |&larr; &#8592;
      |&plusmn; &#177;
    INPUT
      |.PP
      |\\[pc] \\[pc]
      |\\[co] \\[co]
      |\\[ct] \\[ct]
      |\\[dd] \\[dd]
      |\\[de] \\[de]
      |\\[dg] \\[dg]
      |\\[dq] \\[dq]
      |\\[em] \\[em]
      |\\[en] \\[en]
      |\\[rg] \\[rg]
      |\\[sc] \\[sc]
      |\\[rn] \\[rn]
      |\\[==] \\[==]
      |\\[>=] \\[>=]
      |\\[<=] \\[<=]
      |\\[!=] \\[!=]
      |\\[->] \\[->]
      |\\[<-] \\[<-]
      |\\[+-] \\[+-]
    OUTPUT
  end

  it 'renders tables' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |First Header  | Second Header
      |------------- | -------------
      |First Content | Second Content
    INPUT
      |.TS
      |allbox;
      |cb cb
      |l l
      |.
      |First Header\tSecond Header
      |First Content\tSecond Content
      |.TE
    OUTPUT
  end

  it 'renders tables with alignment' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      || Item      | Value |
      || --------- | -----:|
      || Computer  | $1600 |
      || Phone     |   $12 |
      || Pipe      |    $1 |
    INPUT
      |.TS
      |allbox;
      |cb cb
      |l r
      |l r
      |l r
      |.
      |Item\tValue
      |Computer\t$1600
      |Phone\t$12
      |Pipe\t$1
      |.TE
    OUTPUT
  end

  it 'does not break surrounding Markdown while processing references' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |For example, the `printf(3)` cross reference would be emitted as this HTML:
      |
      |    <a class="md2man-reference" href="../man3/printf.3.html">printf(3)</a>
    INPUT
      |.PP
      |For example, the \\fB\\fCprintf(3)\\fR cross reference would be emitted as this HTML:
      |.PP
      |.RS
      |.nf
      |<a class="md2man\\-reference" href="../man3/printf.3.html">printf(3)</a>
      |.fi
      |.RE
    OUTPUT
  end

  it 'renders references to other man pages as hyperlinks' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |convert them from markdown(7) into roff(7), using
    INPUT
      |.PP
      |convert them from#{SPACE}
      |.BR markdown (7)#{SPACE}
      |into#{SPACE}
      |.BR roff (7),#{SPACE}
      |using
    OUTPUT
  end

  it 'does not render references inside code blocks' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |    this is a code block
      |    containing markdown(7),
      |    roff(7), and much more!
    INPUT
      |.PP
      |.RS
      |.nf
      |this is a code block
      |containing markdown(7),
      |roff(7), and much more!
      |.fi
      |.RE
    OUTPUT
  end

  it 'does not render references inside code spans' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |this is a code span `containing markdown(7), roff(7), and` much more!
    INPUT
      |.PP
      |this is a code span \\fB\\fCcontaining markdown(7), roff(7), and\\fR much more!
    OUTPUT
  end

  it 'renders references inside image descriptions' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |![Obligatory screenshot of md2man-roff(1) in action!](
      |https://raw.github.com/sunaku/md2man/master/EXAMPLE.png)
    INPUT
      |.PP
      |[Obligatory screenshot of#{SPACE}
      |.BR md2man-roff (1)#{SPACE}
      |in action!](
      |\\[la]https://raw.github.com/sunaku/md2man/master/EXAMPLE.png\\[ra])
    OUTPUT
  end

  it 'renders references to manual pages present on my linux box' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |man(1)
      |man-pages(7)
      |ld.so(8)
      |ld-linux.so(8)
      |ld-linux(8)
      |aio.h(0p)
      |vi(1p)
      |vfork(3p)
      |exit(3tcl)
    INPUT
      |.PP
      |.BR man (1)
      |.BR man-pages (7)
      |.BR ld.so (8)
      |.BR ld-linux.so (8)
      |.BR ld-linux (8)
      |.BR aio.h (0p)
      |.BR vi (1p)
      |.BR vfork (3p)
      |.BR exit (3tcl)
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
      |.SS Macros
      |.PP
      |.RS
      |.nf
      |#define PIPES_GET_LAST(CHAIN)
      |#define PIPES_GET_IN(CHAIN)
      |#define PIPES_GET_OUT(CHAIN)
      |#define PIPES_GET_ERR(CHAIN)
      |.fi
      |.RE
      |.SS \\fB\\fCPIPES_GET_LAST(CHAIN)\\fR
    OUTPUT
  end

  it 'supports sole space or tab in codespans' do
    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |`\s`
    INPUT
      |.PP
      |\\fB\\fC\s\\fR
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |`\t`
    INPUT
      |.PP
      |\\fB\\fC\s\\fR
    OUTPUT

    @markdown.render(heredoc(<<-INPUT)).must_equal(heredoc(<<-OUTPUT))
      |`\n`
    INPUT
      |.PP
      |\\fB\\fC\n\\fR
    OUTPUT
  end
end
