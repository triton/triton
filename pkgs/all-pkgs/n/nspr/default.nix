{ stdenv
, fetchurl
, lib
}:

let
  inherit (lib)
    elem
    optionals
    platforms;

  version = "4.23";

  baseUrls = [
    "https://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v${version}/src"
  ];
in
stdenv.mkDerivation rec {
  name = "nspr-${version}";

  src = fetchurl {
    urls = map (n: "${n}/nspr-${version}.tar.gz") baseUrls;
    multihash = "QmbnDUBHks9q1yMwaYQSDFk1Z3Bai12TRVDCMvQQK4Pt5o";
    hashOutput = false;
    sha256 = "4b9d821037faf5723da901515ed9cac8b23ef1ea3729022259777393453477a4";
  };

  prePatch = ''
    cd nspr
  '';

  configureFlags = optionals (elem stdenv.targetSystem platforms.bit64) [
    "--enable-64bit"
  ];

  postInstall = ''
    mkdir -p "$dev"/bin2
    mv -v "$dev"/bin/*-config "$dev"/bin2
    rm -rv "$dev"/bin
    mv -v "$dev"/bin2 "$dev"/bin

    mkdir -p "$lib"/lib
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  outputs = [
    "dev"
    "lib"
  ];

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
