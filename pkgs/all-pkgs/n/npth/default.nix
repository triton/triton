{ stdenv
, fetchurl
, gnupg
}:

let
  tarballUrls = version: [
    "mirror://gnupg/npth/npth-${version}.tar.bz2"
  ];

  version = "1.6";
in
stdenv.mkDerivation rec {
  name = "npth-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "1393abd9adcf0762d34798dc34fdcf4d0d22a8410721e76f1e3afcd1daa4e2d1";
  };

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.6";
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerification) pgpKeyFingerprints;
      outputHash = "1393abd9adcf0762d34798dc34fdcf4d0d22a8410721e76f1e3afcd1daa4e2d1";
      inherit (src) outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "The New GNU Portable Threads Library";
    homepage = http://www.gnupg.org;
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
