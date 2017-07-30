{ stdenv
, fetchurl
, lib
}:

let
  inherit (lib)
    elem
    optionals
    platforms;

  version = "4.16";

  baseUrls = [
    "https://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v${version}/src"
  ];
in
stdenv.mkDerivation rec {
  name = "nspr-${version}";

  src = fetchurl {
    urls = map (n: "${n}/nspr-${version}.tar.gz") baseUrls;
    hashOutput = false;
    sha256 = "9b3102d97665504aeee73363c11a21c062ad67a2522242368b7f019f96a53cd1";
  };

  prePatch = ''
    cd nspr
  '';

  configureFlags = [
    "--enable-optimize"
    "--disable-debug"
  ] ++ optionals (elem stdenv.targetSystem platforms.bit64) [
    "--enable-64bit"
  ];

  # We don't want to keep any static libraries
  postInstall = ''
    find $out -name "*.a" -delete
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Urls = map (n: "${n}/SHA256SUMS") baseUrls;
      failEarly = true;
    };
  };

  meta = with lib; {
    homepage = http://www.mozilla.org/projects/nspr/;
    description = "Netscape Portable Runtime, a platform-neutral API for system-level and libc-like functions";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
