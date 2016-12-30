{ stdenv
, fetchurl

, boost
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

  version = "1.18.0";
in
stdenv.mkDerivation rec {
  name = "${prefix}nghttp2-${version}";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/nghttp2/releases/download/"
      + "v${version}/nghttp2-${version}.tar.xz";
    sha256 = "5e5620e103f9239c0758e0fbfcf9bc04744794c1ce7a415583fbd4c2671a4499";
  };

  buildInputs = optionals (!isLib) [
    boost
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
