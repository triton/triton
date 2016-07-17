{ stdenv
, fetchurl

, c-ares
, libssh2
, libxml2
, openssl
, sqlite
, zlib
}:

stdenv.mkDerivation rec {
  name = "aria2-${version}";
  version = "1.25.0";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/aria2/releases/download/"
      + "release-${version}/${name}.tar.xz";
    sha256 = "ff89eb4c76cfc816a6f5abc7dfd416cc3f339e7d02c761f822fa965a18cf0d35";
  };

  buildInputs = [
    openssl
    c-ares
    libxml2
    sqlite
    zlib
    libssh2
  ];

  configureFlags = [
    "--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
  ];

  meta = with stdenv.lib; {
    description = "A multi-protocol/source, command-line download utility";
    homepage = https://github.com/tatsuhiro-t/aria2;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
