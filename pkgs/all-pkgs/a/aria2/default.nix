{ stdenv
, fetchurl

, c-ares
, libssh2
, libxml2
, openssl
, sqlite
, zlib
}:

let
  version = "1.27.1";
in
stdenv.mkDerivation rec {
  name = "aria2-${version}";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/aria2/releases/download/"
      + "release-${version}/${name}.tar.xz";
    sha256 = "c09627ef31602cfdfa7c9925a6c3b05fe7d2097d83f42dcfdef68664bd106f08";
  };

  buildInputs = [
    c-ares
    libssh2
    libxml2
    openssl
    sqlite
    zlib
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
