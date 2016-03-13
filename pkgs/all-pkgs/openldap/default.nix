{ stdenv
, fetchurl
, groff

, cyrus-sasl
, db
, openssl
}:

stdenv.mkDerivation rec {
  name = "openldap-2.4.44";

  src = fetchurl {
    url = "http://www.openldap.org/software/download/OpenLDAP/openldap-release/${name}.tgz";
    sha256 = "0044p20hx07fwgw2mbwj1fkx04615hhs1qyx4mawj2bhqvrnppnp";
  };

  nativeBuildInputs = [
    groff
  ];

  buildInputs = [
    cyrus-sasl
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
