{ stdenv
, fetchurl
}:

let
  inherit (stdenv.lib)
    elem
    optionals
    platforms;

  version = "4.13.1";

  baseUrls = [
    "https://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v${version}/src"
  ];
in
stdenv.mkDerivation rec {
  name = "nspr-${version}";

  src = fetchurl {
    urls = map (n: "${n}/nspr-${version}.tar.gz") baseUrls;
    hashOutput = false;
    sha256 = "5e4c1751339a76e7c772c0c04747488d7f8c98980b434dc846977e43117833ab";
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

  meta = with stdenv.lib; {
    homepage = http://www.mozilla.org/projects/nspr/;
    description = "Netscape Portable Runtime, a platform-neutral API for system-level and libc-like functions";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
