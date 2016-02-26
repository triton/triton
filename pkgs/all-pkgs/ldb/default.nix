{ stdenv
, docbook_xml_dtd_42
, docbook_xsl
, fetchurl
, libxslt
, python

, popt
, talloc
, tdb
, tevent
}:

stdenv.mkDerivation rec {
  name = "ldb-1.1.26";

  src = fetchurl {
    url = "mirror://samba/ldb/${name}.tar.gz";
    sha256 = "1rmjv12pf57vga8s5z9p9d90rlfckc1lqjbcp89r83cq5fkwfhw8";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_42
    docbook_xsl
    libxslt
    python
  ];

  buildInputs = [
    talloc
    tdb
    tevent
    popt
  ];

  postPatch = ''
    patchShebangs buildtools/bin/waf
  '';

  configureFlags = [
    "--bundled-libraries=NONE"
    "--builtin-libraries=replace"
  ];

  meta = with stdenv.lib; {
    description = "a LDAP-like embedded database";
    homepage = http://ldb.samba.org/;
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [ wkennington ];
    platforms = platforms.all;
  };
}
