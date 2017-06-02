{ stdenv
, fetchurl
, gnupg
}:

let
  tarballUrls = version: [
    "mirror://gnupg/npth/npth-${version}.tar.bz2"
  ];

  version = "1.5";
in
stdenv.mkDerivation rec {
  name = "npth-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "294a690c1f537b92ed829d867bee537e46be93fbd60b16c04630fbbfcd9db3c2";
  };

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.5";
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerification) pgpKeyFingerprints;
      outputHash = "294a690c1f537b92ed829d867bee537e46be93fbd60b16c04630fbbfcd9db3c2";
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
