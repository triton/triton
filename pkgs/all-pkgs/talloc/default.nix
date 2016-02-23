{ stdenv
, docbook_xsl
, docbook_xml_dtd_42
, fetchurl
, python2
, libxslt
}:

stdenv.mkDerivation rec {
  name = "talloc-2.1.5";

  src = fetchurl {
    url = "mirror://samba/talloc/${name}.tar.gz";
    sha256 = "1pfx3kmj973hpacfw46fzfnjd7ms1j03ifkc30wk930brx8ffcrq";
  };

  nativeBuildInputs = [
    docbook_xsl
    docbook_xml_dtd_42
    libxslt
    python2
  ];

  preConfigure = ''
    patchShebangs buildtools/bin/waf
  '';

  configureFlags = [
    "--enable-talloc-compat1"
    "--bundled-libraries=NONE"
    "--builtin-libraries=replace"
  ];

  meta = with stdenv.lib; {
    description = "Hierarchical pool based memory allocator with destructors";
    homepage = http://tdb.samba.org/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
