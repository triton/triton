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
  isLib = prefix == "lib";
  inherit (stdenv.lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "${prefix}nghttp2-${version}";
  version = "1.9.1";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/nghttp2/releases/download/v${version}/nghttp2-${version}.tar.xz";
    sha256 = "b8f8a0a1abac50da1eeb9238d0dadcda9725a7fe95eb0b4f7a482beabaf2b5fb";
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
    "--${if isLib then "with" else "without"}-libonly"
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
