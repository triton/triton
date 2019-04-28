{ stdenv
, fetchTritonPatch
, fetchurl

, gnupg
}:

let
  tarballUrls = version: [
    "mirror://gnupg/libgpg-error/libgpg-error-${version}.tar.bz2"
  ];

  version = "1.36";
in
stdenv.mkDerivation rec {
  name = "libgpg-error-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "babd98437208c163175c29453f8681094bcaf92968a15cafb1a276076b33c97c";
  };

  patches = [
    (fetchTritonPatch {
      rev = "56da90ce73ac420442e01707c863a5a7b2472de2";
      file = "l/libgpg-error/fix-gawk5.patch";
      sha256 = "7b56221595b8a9343a91171c05f1e195130605e4853fc3ddbb9e90fad20b9507";
    })
  ];

  postPatch = ''
    sed '/BUILD_TIMESTAMP=/s/=.*/=1970-01-01T00:01+0000/' -i ./configure
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.36";
      outputHash = "babd98437208c163175c29453f8681094bcaf92968a15cafb1a276076b33c97c";
      inherit (src) outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        inherit (gnupg.srcVerification) pgpKeyFingerprints;
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = "https://www.gnupg.org/related_software/libgpg-error/index.html";
    description = "A small library that defines common error values for all GnuPG components";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

