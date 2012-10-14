require 'md2man/document'

module Md2Man::Roff

  include Md2Man::Document

  #---------------------------------------------------------------------------
  # document-level processing
  #---------------------------------------------------------------------------

  def preprocess document
    @ordered_list_id = 0
    @table_cells = {}
    @h1_seen = false
    super
  end

  def postprocess document
    super.strip.

    # ensure that spaces after URLs appear properly
    gsub(/(^\.[UM]E) \s/, "\\1\n").

    # squeeze blank lines to prevent double-spaced output
    gsub(/^\n/, '')
  end

  #---------------------------------------------------------------------------
  # block-level processing
  #---------------------------------------------------------------------------

  def indented_paragraph text
    "\n.IP\n#{text}\n"
  end

  def tagged_paragraph text
    "\n.TP\n#{text}\n"
  end

  def normal_paragraph text
    "\n.PP\n#{text}\n"
  end

  def block_code code, language
    code = escape_backslashes(super)
    block_quote "\n.nf\n#{code.chomp}\n.fi\n"
  end

  def block_quote quote
    "\n.PP\n.RS\n#{remove_leading_pp(quote).chomp}\n.RE\n"
  end

  def block_html html
    warn "md2man/roff: block_html not implemented: #{html.inspect}"
  end

  def header text, level
    macro =
      case level
      when 1
        if @h1_seen
          :SH
        else
          @h1_seen = true
          :TH
        end
      when 2 then :SH
      else :SS
      end
    "\n.#{macro} #{text.chomp}\n"
  end

  def hrule
    "\n.ti 0\n\\l'\\n(.lu'\n"
  end

  def list contents, list_type
    result = []

    if list_type == :ordered
      result << ".nr step#{@ordered_list_id} 0 1"
      @ordered_list_id += 1
    end

    result << ".RS\n#{contents}\n.RE\n"
    result.join("\n")
  end

  def list_item text, list_type
    designator =
      case list_type
      when :ordered
        "\\n+[step#{@ordered_list_id}]"
      when :unordered
        "\\(bu 2"
      end

    ".IP #{designator}\n#{remove_leading_pp(text).lstrip.chomp}\n"
  end

  def table header, body
    head_rows = decode_table_rows(header)
    body_rows = decode_table_rows(body)

    ".TS\nallbox;\n#{
      [
        head_rows.map do |row|
          (['cb'] * row.length).join(TABLE_COL_DELIM)
        end,
        body_rows.map do |row|
          row.map do |content, alignment|
            (alignment || :left).to_s[0,1]
          end.join(TABLE_COL_DELIM)
        end
      ].join(TABLE_ROW_DELIM)
    }\n.\n#{
      (head_rows + body_rows).map do |row|
        row.map(&:first).join(TABLE_CELL_DELIM)
      end.join(TABLE_ROW_DELIM)
    }\n.TE\n"
  end

  def table_row content
    encode_table_row content
  end

  def table_cell content, alignment
    encode_table_cell [content, alignment]
  end

  #---------------------------------------------------------------------------
  # span-level processing
  #---------------------------------------------------------------------------

  def reference page, section, addendum
    "\n.BR #{page} (#{section})#{addendum}\n"
  end

  def linebreak
    "\n.br\n"
  end

  def emphasis text
    "\\fI#{text}\\fP"
  end

  def double_emphasis text
    "\\fB#{text}\\fP"
  end

  def triple_emphasis text
    "\\s+2#{double_emphasis text}\\s-2"
  end

  def strikethrough text
    warn "md2man/roff: strikethrough not implemented: #{text.inspect}"
  end

  def superscript text
    warn "md2man/roff: superscript not implemented: #{text.inspect}"
  end

  def codespan code
    code = escape_backslashes(super)
    # NOTE: this double font sequence gives us the best of both worlds:
    # man(1) shows it in bold and `groff -Thtml` shows it in monospace
    "\\fB\\fC#{code}\\fR"
  end

  def link link, title, content
    content +
    if link =~ /^mailto:/
      autolink $', :email
    else
      autolink link, :url
    end
  end

  def autolink link, link_type
    if link_type == :email
      "\n.MT #{link.chomp}\n.ME "
    else
      "\n.UR #{link.chomp}\n.UE "
    end
  end

  def image link, title, alt_text
    warn "md2man/roff: image not implemented: #{link.inspect}"
  end

  def raw_html html
    warn "md2man/roff: raw_html not implemented: #{html.inspect}"
  end

  #---------------------------------------------------------------------------
  # low-level processing
  #---------------------------------------------------------------------------

  def normal_text text
    text.gsub('-', '\\-') if text
  end

  def entity text
    if unicode = entity_to_unicode(text)
      unicode_to_glyph unicode
    else
      warn "md2man/roff: entity not implemented: #{text.inspect}"
    end
  end

private

  def escape_backslashes text
    text.gsub(/\\/, '\&\&')
  end

  def remove_leading_pp text
    text.sub(/\A\n\.PP\n/, '')
  end

  TABLE_COL_DELIM = ' '
  TABLE_ROW_DELIM = "\n"
  TABLE_CELL_DELIM = "\t"

  def decode_table_rows rows
    rows.split(TABLE_ROW_DELIM).map do |row|
      row.split(TABLE_CELL_DELIM).map do |cell|
        @table_cells.delete cell
      end
    end
  end

  def encode_table_row row
    row + TABLE_ROW_DELIM
  end

  def encode_table_cell cell
    key = encode(cell)
    @table_cells[key] = cell
    key + TABLE_CELL_DELIM
  end

  def entity_to_unicode entity
    if ENTITY_TO_UNICODE.key? entity
      ENTITY_TO_UNICODE[entity]
    elsif entity =~ /^&#(\d+);$/
      $1.to_i
    elsif entity =~ /^&#x(\h+);$/
      $1.to_i(16)
    end
  end

  def unicode_to_glyph unicode
    if UNICODE_TO_GLYPH.key? unicode
      UNICODE_TO_GLYPH[unicode]
    elsif unicode < 256
      '\\[char%d]' % unicode
    else
      '\\[u%04x]' % unicode
    end
  end

  # see http://www.w3.org/TR/xhtml1/dtds.html#h-A2
  # see http://www.w3.org/TR/html4/sgml/entities.html
  ENTITY_TO_UNICODE = {
    '&quot;'     => 0x0022,
    '&amp;'      => 0x0026,
    '&apos;'     => 0x0027,
    '&lt;'       => 0x003c,
    '&gt;'       => 0x003e,
    '&nbsp;'     => 0x00a0,
    '&iexcl;'    => 0x00a1,
    '&cent;'     => 0x00a2,
    '&pound;'    => 0x00a3,
    '&curren;'   => 0x00a4,
    '&yen;'      => 0x00a5,
    '&brvbar;'   => 0x00a6,
    '&sect;'     => 0x00a7,
    '&uml;'      => 0x00a8,
    '&copy;'     => 0x00a9,
    '&ordf;'     => 0x00aa,
    '&laquo;'    => 0x00ab,
    '&not;'      => 0x00ac,
    '&shy;'      => 0x00ad,
    '&reg;'      => 0x00ae,
    '&macr;'     => 0x00af,
    '&deg;'      => 0x00b0,
    '&plusmn;'   => 0x00b1,
    '&sup2;'     => 0x00b2,
    '&sup3;'     => 0x00b3,
    '&acute;'    => 0x00b4,
    '&micro;'    => 0x00b5,
    '&para;'     => 0x00b6,
    '&middot;'   => 0x00b7,
    '&cedil;'    => 0x00b8,
    '&sup1;'     => 0x00b9,
    '&ordm;'     => 0x00ba,
    '&raquo;'    => 0x00bb,
    '&frac14;'   => 0x00bc,
    '&frac12;'   => 0x00bd,
    '&frac34;'   => 0x00be,
    '&iquest;'   => 0x00bf,
    '&Agrave;'   => 0x00c0,
    '&Aacute;'   => 0x00c1,
    '&Acirc;'    => 0x00c2,
    '&Atilde;'   => 0x00c3,
    '&Auml;'     => 0x00c4,
    '&Aring;'    => 0x00c5,
    '&AElig;'    => 0x00c6,
    '&Ccedil;'   => 0x00c7,
    '&Egrave;'   => 0x00c8,
    '&Eacute;'   => 0x00c9,
    '&Ecirc;'    => 0x00ca,
    '&Euml;'     => 0x00cb,
    '&Igrave;'   => 0x00cc,
    '&Iacute;'   => 0x00cd,
    '&Icirc;'    => 0x00ce,
    '&Iuml;'     => 0x00cf,
    '&ETH;'      => 0x00d0,
    '&Ntilde;'   => 0x00d1,
    '&Ograve;'   => 0x00d2,
    '&Oacute;'   => 0x00d3,
    '&Ocirc;'    => 0x00d4,
    '&Otilde;'   => 0x00d5,
    '&Ouml;'     => 0x00d6,
    '&times;'    => 0x00d7,
    '&Oslash;'   => 0x00d8,
    '&Ugrave;'   => 0x00d9,
    '&Uacute;'   => 0x00da,
    '&Ucirc;'    => 0x00db,
    '&Uuml;'     => 0x00dc,
    '&Yacute;'   => 0x00dd,
    '&THORN;'    => 0x00de,
    '&szlig;'    => 0x00df,
    '&agrave;'   => 0x00e0,
    '&aacute;'   => 0x00e1,
    '&acirc;'    => 0x00e2,
    '&atilde;'   => 0x00e3,
    '&auml;'     => 0x00e4,
    '&aring;'    => 0x00e5,
    '&aelig;'    => 0x00e6,
    '&ccedil;'   => 0x00e7,
    '&egrave;'   => 0x00e8,
    '&eacute;'   => 0x00e9,
    '&ecirc;'    => 0x00ea,
    '&euml;'     => 0x00eb,
    '&igrave;'   => 0x00ec,
    '&iacute;'   => 0x00ed,
    '&icirc;'    => 0x00ee,
    '&iuml;'     => 0x00ef,
    '&eth;'      => 0x00f0,
    '&ntilde;'   => 0x00f1,
    '&ograve;'   => 0x00f2,
    '&oacute;'   => 0x00f3,
    '&ocirc;'    => 0x00f4,
    '&otilde;'   => 0x00f5,
    '&ouml;'     => 0x00f6,
    '&divide;'   => 0x00f7,
    '&oslash;'   => 0x00f8,
    '&ugrave;'   => 0x00f9,
    '&uacute;'   => 0x00fa,
    '&ucirc;'    => 0x00fb,
    '&uuml;'     => 0x00fc,
    '&yacute;'   => 0x00fd,
    '&thorn;'    => 0x00fe,
    '&yuml;'     => 0x00ff,
    '&OElig;'    => 0x0152,
    '&oelig;'    => 0x0153,
    '&Scaron;'   => 0x0160,
    '&scaron;'   => 0x0161,
    '&Yuml;'     => 0x0178,
    '&fnof;'     => 0x0192,
    '&circ;'     => 0x02c6,
    '&tilde;'    => 0x02dc,
    '&Alpha;'    => 0x0391,
    '&Beta;'     => 0x0392,
    '&Gamma;'    => 0x0393,
    '&Delta;'    => 0x0394,
    '&Epsilon;'  => 0x0395,
    '&Zeta;'     => 0x0396,
    '&Eta;'      => 0x0397,
    '&Theta;'    => 0x0398,
    '&Iota;'     => 0x0399,
    '&Kappa;'    => 0x039a,
    '&Lambda;'   => 0x039b,
    '&Mu;'       => 0x039c,
    '&Nu;'       => 0x039d,
    '&Xi;'       => 0x039e,
    '&Omicron;'  => 0x039f,
    '&Pi;'       => 0x03a0,
    '&Rho;'      => 0x03a1,
    '&Sigma;'    => 0x03a3,
    '&Tau;'      => 0x03a4,
    '&Upsilon;'  => 0x03a5,
    '&Phi;'      => 0x03a6,
    '&Chi;'      => 0x03a7,
    '&Psi;'      => 0x03a8,
    '&Omega;'    => 0x03a9,
    '&alpha;'    => 0x03b1,
    '&beta;'     => 0x03b2,
    '&gamma;'    => 0x03b3,
    '&delta;'    => 0x03b4,
    '&epsilon;'  => 0x03b5,
    '&zeta;'     => 0x03b6,
    '&eta;'      => 0x03b7,
    '&theta;'    => 0x03b8,
    '&iota;'     => 0x03b9,
    '&kappa;'    => 0x03ba,
    '&lambda;'   => 0x03bb,
    '&mu;'       => 0x03bc,
    '&nu;'       => 0x03bd,
    '&xi;'       => 0x03be,
    '&omicron;'  => 0x03bf,
    '&pi;'       => 0x03c0,
    '&rho;'      => 0x03c1,
    '&sigmaf;'   => 0x03c2,
    '&sigma;'    => 0x03c3,
    '&tau;'      => 0x03c4,
    '&upsilon;'  => 0x03c5,
    '&phi;'      => 0x03c6,
    '&chi;'      => 0x03c7,
    '&psi;'      => 0x03c8,
    '&omega;'    => 0x03c9,
    '&thetasym;' => 0x03d1,
    '&upsih;'    => 0x03d2,
    '&piv;'      => 0x03d6,
    '&ensp;'     => 0x2002,
    '&emsp;'     => 0x2003,
    '&thinsp;'   => 0x2009,
    '&zwnj;'     => 0x200c,
    '&zwj;'      => 0x200d,
    '&lrm;'      => 0x200e,
    '&rlm;'      => 0x200f,
    '&ndash;'    => 0x2013,
    '&mdash;'    => 0x2014,
    '&lsquo;'    => 0x2018,
    '&rsquo;'    => 0x2019,
    '&sbquo;'    => 0x201a,
    '&ldquo;'    => 0x201c,
    '&rdquo;'    => 0x201d,
    '&bdquo;'    => 0x201e,
    '&dagger;'   => 0x2020,
    '&Dagger;'   => 0x2021,
    '&bull;'     => 0x2022,
    '&hellip;'   => 0x2026,
    '&permil;'   => 0x2030,
    '&prime;'    => 0x2032,
    '&Prime;'    => 0x2033,
    '&lsaquo;'   => 0x2039,
    '&rsaquo;'   => 0x203a,
    '&oline;'    => 0x203e,
    '&frasl;'    => 0x2044,
    '&euro;'     => 0x20ac,
    '&image;'    => 0x2111,
    '&weierp;'   => 0x2118,
    '&real;'     => 0x211c,
    '&trade;'    => 0x2122,
    '&alefsym;'  => 0x2135,
    '&larr;'     => 0x2190,
    '&uarr;'     => 0x2191,
    '&rarr;'     => 0x2192,
    '&darr;'     => 0x2193,
    '&harr;'     => 0x2194,
    '&crarr;'    => 0x21b5,
    '&lArr;'     => 0x21d0,
    '&uArr;'     => 0x21d1,
    '&rArr;'     => 0x21d2,
    '&dArr;'     => 0x21d3,
    '&hArr;'     => 0x21d4,
    '&forall;'   => 0x2200,
    '&part;'     => 0x2202,
    '&exist;'    => 0x2203,
    '&empty;'    => 0x2205,
    '&nabla;'    => 0x2207,
    '&isin;'     => 0x2208,
    '&notin;'    => 0x2209,
    '&ni;'       => 0x220b,
    '&prod;'     => 0x220f,
    '&sum;'      => 0x2211,
    '&minus;'    => 0x2212,
    '&lowast;'   => 0x2217,
    '&radic;'    => 0x221a,
    '&prop;'     => 0x221d,
    '&infin;'    => 0x221e,
    '&ang;'      => 0x2220,
    '&and;'      => 0x2227,
    '&or;'       => 0x2228,
    '&cap;'      => 0x2229,
    '&cup;'      => 0x222a,
    '&int;'      => 0x222b,
    '&there4;'   => 0x2234,
    '&sim;'      => 0x223c,
    '&cong;'     => 0x2245,
    '&asymp;'    => 0x2248,
    '&ne;'       => 0x2260,
    '&equiv;'    => 0x2261,
    '&le;'       => 0x2264,
    '&ge;'       => 0x2265,
    '&sub;'      => 0x2282,
    '&sup;'      => 0x2283,
    '&nsub;'     => 0x2284,
    '&sube;'     => 0x2286,
    '&supe;'     => 0x2287,
    '&oplus;'    => 0x2295,
    '&otimes;'   => 0x2297,
    '&perp;'     => 0x22a5,
    '&sdot;'     => 0x22c5,
    '&lceil;'    => 0x2308,
    '&rceil;'    => 0x2309,
    '&lfloor;'   => 0x230a,
    '&rfloor;'   => 0x230b,
    '&lang;'     => 0x2329,
    '&rang;'     => 0x232a,
    '&loz;'      => 0x25ca,
    '&spades;'   => 0x2660,
    '&clubs;'    => 0x2663,
    '&hearts;'   => 0x2665,
    '&diams;'    => 0x2666,
  }

  # see groff_char(7) and "Special Characters" in groff(7)
  UNICODE_TO_GLYPH = {
    0x0022  => "\\[dq]",
    0x0023  => "\\[sh]",
    0x0024  => "\\[Do]",
    0x0026  => '&',
    0x0027  => "\\[aq]",
    0x002b  => "\\[pl]",
    0x002f  => "\\[sl]",
    0x003c  => '<',
    0x003d  => "\\[eq]",
    0x003e  => '>',
    0x0040  => "\\[at]",
    0x005b  => "\\[lB]",
    0x005c  => "\\[rs]",
    0x005d  => "\\[rB]",
    0x005e  => "\\[ha]",
    0x005f  => "\\[nl]",
    0x007b  => "\\[lC]",
    0x007c  => "\\[ba]",
    #0x007c => "\\[or]",
    0x007d  => "\\[rC]",
    0x007e  => "\\[ti]",
    0x00a0  => "\\~",
    0x00a1  => "\\[r!]",
    0x00a2  => "\\[ct]",
    0x00a3  => "\\[Po]",
    0x00a4  => "\\[Cs]",
    0x00a5  => "\\[Ye]",
    0x00a6  => "\\[bb]",
    0x00a7  => "\\[sc]",
    0x00a8  => "\\[ad]",
    0x00a9  => "\\[co]",
    0x00aa  => "\\[Of]",
    0x00ab  => "\\[Fo]",
    0x00ac  => "\\[no]",
    #0x00ac => "\\[tno]",
    0x00ad  => '-',
    0x00ae  => "\\[rg]",
    0x00af  => "\\[a-]",
    0x00b0  => "\\[de]",
    0x00b1  => "\\[+-]",
    #0x00b1 => "\\[t+-]",
    0x00b2  => "\\[S2]",
    0x00b3  => "\\[S3]",
    0x00b4  => "\\[aa]",
    0x00b5  => "\\[mc]",
    0x00b6  => "\\[ps]",
    0x00b7  => "\\[pc]",
    0x00b8  => "\\[ac]",
    0x00b9  => "\\[S1]",
    0x00ba  => "\\[Om]",
    0x00bb  => "\\[Fc]",
    0x00bc  => "\\[14]",
    0x00bd  => "\\[12]",
    0x00be  => "\\[34]",
    0x00bf  => "\\[r?]",
    0x00c0  => "\\[`A]",
    0x00c1  => "\\['A]",
    0x00c2  => "\\[^A]",
    0x00c3  => "\\[~A]",
    0x00c4  => "\\[:A]",
    0x00c5  => "\\[oA]",
    0x00c6  => "\\[AE]",
    0x00c7  => "\\[,C]",
    0x00c8  => "\\[`E]",
    0x00c9  => "\\['E]",
    0x00ca  => "\\[^E]",
    0x00cb  => "\\[:E]",
    0x00cc  => "\\[`I]",
    0x00cd  => "\\['I]",
    0x00ce  => "\\[^I]",
    0x00cf  => "\\[:I]",
    0x00d0  => "\\[-D]",
    0x00d1  => "\\[~N]",
    0x00d2  => "\\[`O]",
    0x00d3  => "\\['O]",
    0x00d4  => "\\[^O]",
    0x00d5  => "\\[~O]",
    0x00d6  => "\\[:O]",
    0x00d7  => "\\[mu]",
    #0x00d7 => "\\[tmu]",
    0x00d8  => "\\[/O]",
    0x00d9  => "\\[`U]",
    0x00da  => "\\['U]",
    0x00db  => "\\[^U]",
    0x00dc  => "\\[:U]",
    0x00dd  => "\\['Y]",
    0x00de  => "\\[TP]",
    0x00df  => "\\[ss]",
    0x00e0  => "\\[`a]",
    0x00e1  => "\\['a]",
    0x00e2  => "\\[^a]",
    0x00e3  => "\\[~a]",
    0x00e4  => "\\[:a]",
    0x00e5  => "\\[oa]",
    0x00e6  => "\\[ae]",
    0x00e7  => "\\[,c]",
    0x00e8  => "\\[`e]",
    0x00e9  => "\\['e]",
    0x00ea  => "\\[^e]",
    0x00eb  => "\\[:e]",
    0x00ec  => "\\[`i]",
    0x00ed  => "\\['i]",
    0x00ee  => "\\[^i]",
    0x00ef  => "\\[:i]",
    0x00f0  => "\\[Sd]",
    0x00f1  => "\\[~n]",
    0x00f2  => "\\[`o]",
    0x00f3  => "\\['o]",
    0x00f4  => "\\[^o]",
    0x00f5  => "\\[~o]",
    0x00f6  => "\\[:o]",
    0x00f7  => "\\[di]",
    #0x00f7 => "\\[tdi]",
    0x00f8  => "\\[/o]",
    0x00f9  => "\\[`u]",
    0x00fa  => "\\['u]",
    0x00fb  => "\\[^u]",
    0x00fc  => "\\[:u]",
    0x00fd  => "\\['y]",
    0x00fe  => "\\[Tp]",
    0x00ff  => "\\[:y]",
    0x0131  => "\\[.i]",
    0x0132  => "\\[IJ]",
    0x0133  => "\\[ij]",
    0x0141  => "\\[/L]",
    0x0142  => "\\[/l]",
    0x0152  => "\\[OE]",
    0x0153  => "\\[oe]",
    0x0160  => "\\[vS]",
    0x0161  => "\\[vs]",
    0x0178  => "\\[:Y]",
    0x0192  => "\\[Fn]",
    0x02c6  => "\\[a^]",
    0x02dc  => "\\[a~]",
    0x0300  => "\\[ga]",
    0x0301  => "\\[aa]",
    0x0302  => "\\[a^]",
    0x0303  => "\\[a~]",
    0x0304  => "\\[a-]",
    0x0306  => "\\[ab]",
    0x0307  => "\\[a.]",
    0x0308  => "\\[ad]",
    0x030a  => "\\[ao]",
    0x030b  => '\\[a"]',
    0x030c  => "\\[ah]",
    0x0327  => "\\[ac]",
    0x0328  => "\\[ho]",
    0x0391  => "\\[*A]",
    0x0392  => "\\[*B]",
    0x0393  => "\\[*G]",
    0x0394  => "\\[*D]",
    0x0395  => "\\[*E]",
    0x0396  => "\\[*Z]",
    0x0397  => "\\[*Y]",
    0x0398  => "\\[*H]",
    0x0399  => "\\[*I]",
    0x039a  => "\\[*K]",
    0x039b  => "\\[*L]",
    0x039c  => "\\[*M]",
    0x039d  => "\\[*N]",
    0x039e  => "\\[*C]",
    0x039f  => "\\[*O]",
    0x03a0  => "\\[*P]",
    0x03a1  => "\\[*R]",
    0x03a3  => "\\[*S]",
    0x03a4  => "\\[*T]",
    0x03a5  => "\\[*U]",
    0x03a6  => "\\[*F]",
    0x03a7  => "\\[*X]",
    0x03a8  => "\\[*Q]",
    0x03a9  => "\\[*W]",
    0x03b1  => "\\[*a]",
    0x03b2  => "\\[*b]",
    0x03b3  => "\\[*g]",
    0x03b4  => "\\[*d]",
    0x03b5  => "\\[*e]",
    0x03b6  => "\\[*z]",
    0x03b7  => "\\[*y]",
    0x03b8  => "\\[*h]",
    0x03b9  => "\\[*i]",
    0x03ba  => "\\[*k]",
    0x03bb  => "\\[*l]",
    0x03bc  => "\\[*m]",
    0x03bd  => "\\[*n]",
    0x03be  => "\\[*c]",
    0x03bf  => "\\[*o]",
    0x03c0  => "\\[*p]",
    0x03c1  => "\\[*r]",
    0x03c2  => "\\[ts]",
    0x03c3  => "\\[*s]",
    0x03c4  => "\\[*t]",
    0x03c5  => "\\[*u]",
    0x03c6  => "\\[+f]",
    0x03c7  => "\\[*x]",
    0x03c8  => "\\[*q]",
    0x03c9  => "\\[*w]",
    0x03d1  => "\\[+h]",
    0x03d5  => "\\[*f]",
    0x03d6  => "\\[+p]",
    0x03f5  => "\\[+e]",
    0x2010  => "\\[hy]",
    0x2013  => "\\[en]",
    0x2014  => "\\[em]",
    0x2018  => "\\[oq]",
    0x2019  => "\\[cq]",
    0x201a  => "\\[bq]",
    0x201c  => "\\[lq]",
    0x201d  => "\\[rq]",
    0x201e  => "\\[Bq]",
    0x2020  => "\\[dg]",
    0x2021  => "\\[dd]",
    0x2022  => "\\[bu]",
    0x2030  => "\\[%0]",
    0x2032  => "\\[fm]",
    0x2033  => "\\[sd]",
    0x2039  => "\\[fo]",
    0x203a  => "\\[fc]",
    0x203e  => "\\[rn]",
    0x2044  => "\\[f/]",
    #0x20ac => "\\[Eu]",
    0x20ac  => "\\[eu]",
    0x210f  => "\\[-h]",
    #0x210f => "\\[hbar]",
    0x2111  => "\\[Im]",
    0x2118  => "\\[wp]",
    0x211c  => "\\[Re]",
    0x2122  => "\\[tm]",
    0x2135  => "\\[Ah]",
    0x215b  => "\\[18]",
    0x215c  => "\\[38]",
    0x215d  => "\\[58]",
    0x215e  => "\\[78]",
    0x2190  => "\\[<-]",
    0x2191  => "\\[ua]",
    0x2192  => "\\[->]",
    0x2193  => "\\[da]",
    0x2194  => "\\[<>]",
    0x2195  => "\\[va]",
    0x21b5  => "\\[CR]",
    0x21d0  => "\\[lA]",
    0x21d1  => "\\[uA]",
    0x21d2  => "\\[rA]",
    0x21d3  => "\\[dA]",
    0x21d4  => "\\[hA]",
    0x21d5  => "\\[vA]",
    0x2200  => "\\[fa]",
    0x2202  => "\\[pd]",
    0x2203  => "\\[te]",
    0x2205  => "\\[es]",
    0x2207  => "\\[gr]",
    0x2208  => "\\[mo]",
    0x2209  => "\\[nm]",
    0x220b  => "\\[st]",
    0x220f  => "\\[product]",
    0x2210  => "\\[coproduct]",
    0x2211  => "\\[sum]",
    0x2212  => "\\[mi]",
    0x2213  => "\\[-+]",
    0x2217  => "\\[**]",
    #0x221a => "\\[sqrt]",
    0x221a  => "\\[sr]",
    0x221d  => "\\[pt]",
    0x221e  => "\\[if]",
    0x2220  => "\\[/_]",
    0x2227  => "\\[AN]",
    0x2228  => "\\[OR]",
    0x2229  => "\\[ca]",
    0x222a  => "\\[cu]",
    #0x222b => "\\[integral]",
    0x222b  => "\\[is]",
    0x2234  => "\\[3d]",
    #0x2234 => "\\[tf]",
    0x223c  => "\\[ap]",
    0x2243  => "\\[|=]",
    0x2245  => "\\[=~]",
    #0x2248 => "\\[~=]",
    0x2248  => "\\[~~]",
    0x2260  => "\\[!=]",
    0x2261  => "\\[==]",
    0x2264  => "\\[<=]",
    0x2265  => "\\[>=]",
    0x226a  => "\\[<<]",
    0x226b  => "\\[>>]",
    0x2282  => "\\[sb]",
    0x2283  => "\\[sp]",
    0x2284  => "\\[nb]",
    0x2286  => "\\[ib]",
    0x2287  => "\\[ip]",
    0x2295  => "\\[c+]",
    0x2297  => "\\[c*]",
    0x22a5  => "\\[pp]",
    0x22c5  => "\\[md]",
    0x2308  => "\\[lc]",
    0x2309  => "\\[rc]",
    0x230a  => "\\[lf]",
    0x230b  => "\\[rf]",
    0x2329  => "\\[la]",
    0x232a  => "\\[ra]",
    0x239b  => "\\[parenlefttp]",
    0x239c  => "\\[parenleftex]",
    0x239d  => "\\[parenleftbt]",
    0x239e  => "\\[parenrighttp]",
    0x239f  => "\\[parenrightex]",
    0x23a0  => "\\[parenrightbt]",
    0x23a1  => "\\[bracketlefttp]",
    0x23a2  => "\\[bracketleftex]",
    0x23a3  => "\\[bracketleftbt]",
    0x23a4  => "\\[bracketrighttp]",
    0x23a5  => "\\[bracketrightex]",
    0x23a6  => "\\[bracketrightbt]",
    #0x23a7 => "\\[bracelefttp]",
    0x23a7  => "\\[lt]",
    #0x23a8 => "\\[braceleftmid]",
    0x23a8  => "\\[lk]",
    #0x23a9 => "\\[braceleftbt]",
    0x23a9  => "\\[lb]",
    #0x23aa => "\\[braceex]",
    #0x23aa => "\\[braceleftex]",
    #0x23aa => "\\[bracerightex]",
    0x23aa  => "\\[bv]",
    #0x23ab => "\\[bracerighttp]",
    0x23ab  => "\\[rt]",
    #0x23ac => "\\[bracerightmid]",
    0x23ac  => "\\[rk]",
    #0x23ad => "\\[bracerightbt]",
    0x23ad  => "\\[rb]",
    0x23af  => "\\[an]",
    0x2502  => "\\[br]",
    0x25a1  => "\\[sq]",
    0x25ca  => "\\[lz]",
    0x25cb  => "\\[ci]",
    0x261c  => "\\[lh]",
    0x261e  => "\\[rh]",
    0x2660  => "\\[SP]",
    0x2663  => "\\[CL]",
    0x2665  => "\\[HE]",
    0x2666  => "\\[DI]",
    0x2713  => "\\[OK]",
    0x27e8  => "\\[la]",
    0x27e9  => "\\[ra]",
  }

end
