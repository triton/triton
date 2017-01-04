{ stdenv
, fetchurl
, shared ? true
, static ? true
}:

assert static || shared;

let
  version = "1.2.10";

  tarballUrls = version: [
    "http://zlib.net/zlib-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "zlib-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmNdvd5s9vseKCdBQsHuk24B2XHnVNmyUziWQhetFPdroB";
    sha256 = "9612bf086047078ce3a1c154fc9052113fc1a2a97234a059da17a6299bd4dd32";
  };

  configureFlags = [
    (if static then "--static" else "")
    (if shared then "--shared" else "")
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.2.10";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "5ED4 6A67 21D3 6558 7791  E2AA 783F CD8E 58BC AFBA";
      inherit (src) outputHashAlgo;
      outputHash = "9612bf086047078ce3a1c154fc9052113fc1a2a97234a059da17a6299bd4dd32";
    };
  };

  meta = with stdenv.lib; {
    description = "Lossless data-compression library";
    homepage = http://www.zlib.net/;
    license = licenses.zlib;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
