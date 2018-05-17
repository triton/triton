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
  version = "1.34.0";
in
stdenv.mkDerivation rec {
  name = "aria2-${version}";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/aria2/releases/download/"
      + "release-${version}/${name}.tar.xz";
    sha256 = "3a44a802631606e138a9e172a3e9f5bcbaac43ce2895c1d8e2b46f30487e77a3";
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
