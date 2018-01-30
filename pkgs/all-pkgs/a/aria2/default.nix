{ stdenv
, fetchurl

, c-ares
, expat
, jemalloc
, libssh2
, libuv
, openssl
, sqlite
, zlib
}:

let
  version = "1.33.1";
in
stdenv.mkDerivation rec {
  name = "aria2-${version}";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/aria2/releases/download/"
      + "release-${version}/${name}.tar.xz";
    sha256 = "2539e4844f55a1f1f5c46ad42744335266053a69162e964d9a2d80a362c75e1b";
  };

  buildInputs = [
    c-ares
    expat
    jemalloc
    libssh2
    libuv
    openssl
    sqlite
    zlib
  ];

  configureFlags = [
    "--enable-libaria2"
    "--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
    "--with-libuv"
    "--with-jemalloc"
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
