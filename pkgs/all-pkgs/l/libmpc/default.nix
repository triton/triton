{ stdenv
, fetchurl
, gmp
, mpfr
}:

let
  version = "1.0.3";
in
stdenv.mkDerivation rec {
  name = "libmpc-${version}";

  src = fetchurl {
    url = "mirror://gnu/mpc/mpc-${version}.tar.gz";
    hashOutput = false;
    sha256 = "1hzci2zrrd7v3g1jk35qindq05hbl0bhjcyyisq9z209xb3fqzb1";
  };

  buildInputs = [
    gmp
    mpfr
  ];

  doCheck = true;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "AED6 E2A1 85EE B379 F174  76D2 E012 D07A D0E3 CC30";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Library for multiprecision complex arithmetic with exact rounding";
    homepage = http://mpc.multiprecision.org/;
    license = stdenv.lib.licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
