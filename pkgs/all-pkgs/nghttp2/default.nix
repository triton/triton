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
  version = "1.8.0";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/nghttp2/releases/download/v${version}/nghttp2-${version}.tar.xz";
    sha256 = "1v1sfhcihagbi2sizp95mayp63jlqvnkqg2vin8km2bij4llb9b1";
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
