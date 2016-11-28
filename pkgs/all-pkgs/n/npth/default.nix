{ stdenv
, fetchurl
, gnupg
}:

let
  tarballUrls = version: [
    "mirror://gnupg/npth/npth-${version}.tar.bz2"
  ];

  version = "1.3";
in
stdenv.mkDerivation rec {
  name = "npth-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "bca81940436aed0734eb8d0ff8b179e04cc8c087f5625204419f5f45d736a82a";
  };

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.3";
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerification) pgpKeyFingerprints;
      outputHash = "bca81940436aed0734eb8d0ff8b179e04cc8c087f5625204419f5f45d736a82a";
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
