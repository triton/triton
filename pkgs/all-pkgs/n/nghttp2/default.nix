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

  version = "1.39.1";
in
stdenv.mkDerivation rec {
  name = "${prefix}nghttp2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "679160766401f474731fd60c3aca095f88451e3cc4709b72306e4c34cf981448";
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
      url = tarballUrls "1.39.1";
      outputHash = "679160766401f474731fd60c3aca095f88451e3cc4709b72306e4c34cf981448";
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
