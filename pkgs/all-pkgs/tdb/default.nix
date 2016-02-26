{ stdenv
, docbook_xml_dtd_42
, docbook_xsl
, fetchurl
, libxslt
, python

, ncurses
, readline
}:

stdenv.mkDerivation rec {
  name = "tdb-1.3.8";

  src = fetchurl {
    url = "mirror://samba/tdb/${name}.tar.gz";
    sha256 = "1cg6gmpgn36dd4bsp3j9k3hyrm87d8hdigqyyqxw5jga4w2aq186";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_42
    docbook_xsl
    libxslt
    python
  ];

  buildInputs = [
    readline
    ncurses
  ];

  postPatch = ''
    patchShebangs buildtools/bin/waf
  '';

  configureFlags = [
    "--bundled-libraries=NONE"
    "--builtin-libraries=replace"
  ];

  meta = with stdenv.lib; {
    description = "The trivial database";
    homepage = http://tdb.samba.org/;
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
