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
  version = "1.22.0";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/aria2/releases/download/"
      + "release-${version}/${name}.tar.xz";
    sha256 = "ac3fb3f33a76ce22f968ace293445ef64c201b0ae43aef21e664e4b977e34f89";
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
