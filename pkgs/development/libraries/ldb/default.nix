{ stdenv, fetchurl, python, pkgconfig, readline, tdb, talloc, tevent
, popt, libxslt, docbook_xsl, docbook_xml_dtd_42
}:

stdenv.mkDerivation rec {
  name = "ldb-1.1.25";

  src = fetchurl {
    url = "mirror://samba/ldb/${name}.tar.gz";
    sha256 = "04kw5g91l72dlqbgi67kiqqphq8p32lq9qs604jhh974rqz7hx5z";
  };

  buildInputs = [
    python pkgconfig readline tdb talloc tevent popt
    libxslt docbook_xsl docbook_xml_dtd_42
  ];

  preConfigure = ''
    sed -i 's,#!/usr/bin/env python,#!${python}/bin/python,g' buildtools/bin/waf
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
