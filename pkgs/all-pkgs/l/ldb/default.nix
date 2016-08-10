{ stdenv
, docbook_xml_dtd_42
, docbook-xsl
, fetchurl
, libxslt
, python

, popt
, talloc
, tdb
, tevent
}:

stdenv.mkDerivation rec {
  name = "ldb-1.1.27";

  src = fetchurl {
    url = "mirror://samba/ldb/${name}.tar.gz";
    sha256 = "cdb8269cba09006ddf3766eb7721192b52ae3fdc8a6b95f4318b6b740b9d35ac";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_42
    docbook-xsl
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
    description = "An LDAP-like embedded database";
    homepage = http://ldb.samba.org/;
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
