{ stdenv
, fetchurl
, lib

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
  version = "1.35.0";
in
stdenv.mkDerivation rec {
  name = "aria2-${version}";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/aria2/releases/download/"
      + "release-${version}/${name}.tar.xz";
    sha256 = "1e2b7fd08d6af228856e51c07173cfcf987528f1ac97e04c5af4a47642617dfd";
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

  meta = with lib; {
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
