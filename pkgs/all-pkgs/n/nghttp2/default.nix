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

  tarballUrls = version: [
    "https://github.com/tatsuhiro-t/nghttp2/releases/download/v${version}/nghttp2-${version}.tar.xz"
  ];

  version = "1.36.0";
in
stdenv.mkDerivation rec {
  name = "${prefix}nghttp2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "e9bb86157b88eda5a6844a232e039febbb52c1aa44b640acbbfabe729b8287fc";
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

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      url = tarballUrls "1.36.0";
      outputHash = "e9bb86157b88eda5a6844a232e039febbb52c1aa44b640acbbfabe729b8287fc";
      inherit (src)
        outputHashAlgo;
      fullOpts = { };
    };
  };

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
