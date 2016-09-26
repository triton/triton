{ stdenv
, fetchurl

, boost
, jansson
, jemalloc
, libev
, libxml2
, openssl
, zlib

# Extra argument
, prefix ? ""
}:

let
  inherit (stdenv.lib)
    optionals;
in

let
  isLib = prefix == "lib";

  version = "1.15.0";
in
stdenv.mkDerivation rec {
  name = "${prefix}nghttp2-${version}";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/nghttp2/releases/download/v${version}/nghttp2-${version}.tar.xz";
    sha256 = "317afbef79eec624577d006ea7111cf978d2c88e999a6f336c83b99f924b5e4a";
  };

  buildInputs = optionals (!isLib) [
    boost
    jansson
    jemalloc
    libev
    libxml2
    openssl
    zlib
  ];

  configureFlags = [
    "--disable-werror"
    "--disable-debug"
    "--enable-threads"
    "--${if !isLib then "enable" else "disable"}-app"
    "--${if !isLib then "enable" else "disable"}-hpack-tools"
    "--${if !isLib then "enable" else "disable"}-asio-lib"
    "--disable-examples"
    "--disable-python-bindings"
    "--disable-failmalloc"
    "--${if !isLib then "with" else "without"}-libxml2"
    "--${if !isLib then "with" else "without"}-jemalloc"
    "--without-spdylay"
    "--without-neverbleed"
    "--without-cython"
    "--without-mruby"
  ];

  meta = with stdenv.lib; {
    homepage = http://nghttp2.org/;
    description = "an implementation of HTTP/2 in C";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
