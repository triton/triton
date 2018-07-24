{ stdenv
, fetchurl

, gnupg
}:

let
  tarballUrls = version: [
    "mirror://gnupg/libgpg-error/libgpg-error-${version}.tar.bz2"
  ];

  version = "1.32";
in
stdenv.mkDerivation rec {
  name = "libgpg-error-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "c345c5e73cc2332f8d50db84a2280abfb1d8f6d4f1858b9daa30404db44540ca";
  };

  postPatch = ''
    sed '/BUILD_TIMESTAMP=/s/=.*/=1970-01-01T00:01+0000/' -i ./configure
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.32";
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerification) pgpKeyFingerprints;
      outputHash = "c345c5e73cc2332f8d50db84a2280abfb1d8f6d4f1858b9daa30404db44540ca";
      inherit (src) outputHashAlgo;
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

