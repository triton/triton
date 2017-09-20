{ stdenv
, fetchurl

, boost
, c-ares
, cunit
, jansson
, jemalloc
, libev
, libevent
, libxml2
, openssl
, zlib

# Extra argument
, prefix ? ""
}:

let
  inherit (stdenv.lib)
    boolEn
    boolWt
    optionals;
in

let
  isLib = prefix == "lib";

  version = "1.26.0";
in
stdenv.mkDerivation rec {
  name = "${prefix}nghttp2-${version}";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/nghttp2/releases/download/"
      + "v${version}/nghttp2-${version}.tar.xz";
    sha256 = "7ac7ef5c83449303bf38d16eb45caa9e1bd0bb3abb2afc0ab1e6b3aadbded6dd";
  };

  buildInputs = optionals (!isLib) [
    boost
    c-ares
    cunit
    jansson
    jemalloc
    libev
    libevent
    libxml2
    openssl
    zlib
  ];

  configureFlags = [
    "--disable-werror"
    "--disable-debug"
    "--enable-threads"
    "--${boolEn (!isLib)}-app"
    "--${boolEn (!isLib)}-hpack-tools"
    "--${boolEn (!isLib)}-asio-lib"
    "--disable-examples"
    "--disable-python-bindings"
    "--disable-failmalloc"
    "--${boolWt (!isLib)}-libxml2"
    "--${boolWt (!isLib)}-jemalloc"
    "--without-spdylay"
    "--without-neverbleed"
    "--without-cython"
    "--without-mruby"
  ] ++ optionals (!isLib) [
    "--with-boost=${boost.dev}"
    "--with-boost-libdir=${boost.lib}/lib"
  ];

  meta = with stdenv.lib; {
    description = "an implementation of HTTP/2 in C";
    homepage = http://nghttp2.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
