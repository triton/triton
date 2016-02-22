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
    mkEnable
    mkWith
    optionals;
in
stdenv.mkDerivation rec {
  name = "${prefix}nghttp2-${version}";
  version = "1.7.1";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/nghttp2/releases/download/v${version}/nghttp2-${version}.tar.xz";
    sha256 = "05m687bhvrrnqaf18fl6h5y06a4v7j9aai8gmj5cwpflfgfnya7i";
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
    (mkEnable false                 "werror"          null)
    (mkEnable false                 "debug"           null)
    (mkEnable true                  "threads"         null)
    (mkEnable (!isLib)              "app"             null)
    (mkEnable (!isLib)              "hpack-tools"     null)
    (mkEnable (!isLib)              "asio-lib"        null)
    (mkEnable false                 "examples"        null)
    (mkEnable false                 "python-bindings" null)
    (mkEnable false                 "failmalloc"      null)
    (mkWith   (!isLib)              "libxml2"         null)
    (mkWith   (!isLib)              "jemalloc"        null)
    (mkWith   false                 "spdylay"         null)
    (mkWith   false                 "neverbleed"      null)
    (mkWith   false                 "cython"          null)
    (mkWith   false                 "mruby"           null)
    (mkWith   isLib                 "libonly"         null)
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
