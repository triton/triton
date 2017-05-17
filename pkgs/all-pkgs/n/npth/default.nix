{ stdenv
, fetchurl
, gnupg
}:

let
  tarballUrls = version: [
    "mirror://gnupg/npth/npth-${version}.tar.bz2"
  ];

  version = "1.4";
in
stdenv.mkDerivation rec {
  name = "npth-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "8915141836a3169a502d65c1ebd785fcc6d406cae5ee84474272ebf2fa96f1f2";
  };

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.4";
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerification) pgpKeyFingerprints;
      outputHash = "8915141836a3169a502d65c1ebd785fcc6d406cae5ee84474272ebf2fa96f1f2";
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
