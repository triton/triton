{ stdenv
, fetchurl
, groff

, cyrus_sasl
, db
, openssl
}:

stdenv.mkDerivation rec {
  name = "openldap-2.4.43";

  src = fetchurl {
    url = "http://www.openldap.org/software/download/OpenLDAP/openldap-release/${name}.tgz";
    sha256 = "1j3qd65mkm9rg1hbn4xhjdacd671pg6hy1d94q6kdc52k1aqxmrl";
  };

  nativeBuildInputs = [
    groff
  ];

  buildInputs = [
    cyrus_sasl
    db
    openssl
  ];

  configureFlags = [
    "--enable-overlays"
    "--disable-dependency-tracking"   # speeds up one-time build
    "--with-pic"
    "--with-tls"
    "--with-cyrus-sasl"
  ];

  meta = with stdenv.lib; {
    homepage = http://www.openldap.org/;
    description = "An open source implementation of the Lightweight Directory Access Protocol";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
