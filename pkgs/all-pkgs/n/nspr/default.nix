{ stdenv
, fetchurl
, lib
}:

let
  inherit (lib)
    elem
    optionals
    platforms;

  version = "4.21";

  baseUrls = [
    "https://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v${version}/src"
  ];
in
stdenv.mkDerivation rec {
  name = "nspr-${version}";

  src = fetchurl {
    urls = map (n: "${n}/nspr-${version}.tar.gz") baseUrls;
    hashOutput = false;
    sha256 = "15ea32c7b100217b6e3193bc03e77f485d9bf7504051443ba9ce86d1c17c6b5a";
  };

  prePatch = ''
    cd nspr
  '';

  configureFlags = optionals (elem stdenv.targetSystem platforms.bit64) [
    "--enable-64bit"
  ];

  # We don't want to keep any static libraries
  postInstall = ''
    find $out -name "*.a" -delete
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Urls = map (n: "${n}/SHA256SUMS") baseUrls;
      };
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
