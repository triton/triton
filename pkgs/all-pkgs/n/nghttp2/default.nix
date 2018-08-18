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

  version = "1.32.0";
in
stdenv.mkDerivation rec {
  name = "${prefix}nghttp2-${version}";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/nghttp2/releases/download/"
      + "v${version}/nghttp2-${version}.tar.xz";
    sha256 = "700a89d59fcc55acc2b18184001bfb3220fa6a6e543486aca35f40801cba6f7d";
  };

  buildInputs = optionals (!isLib) [
    #boost
    #c-ares
    #cunit
    #jansson
    #jemalloc
    #libev
    #libevent
    #libxml2
    #openssl
    #zlib
  ];

  configureFlags = [
    "--${boolEn (!isLib)}-app"
    "--${boolEn (!isLib)}-hpack-tools"
    "--disable-asio-lib" # Enable eventually
    "--disable-examples"
    "--disable-python-bindings" # Make a separate build for python bindings
    "--disable-failmalloc"
  ];

  postInstall = ''
    rm -r "$out"/{bin,share}
  '';

  meta = with stdenv.lib; {
    description = "an implementation of HTTP/2 in C";
    homepage = http://nghttp2.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
