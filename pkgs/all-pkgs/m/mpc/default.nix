{ stdenv
, fetchurl
, gmp
, mpfr
}:

let
  fileUrls = version: [
    "mirror://gnu/mpc/mpc-${version}.tar.gz"
  ];

  version = "1.1.0";
in
stdenv.mkDerivation rec {
  name = "mpc-${version}";

  src = fetchurl {
    urls = fileUrls version;
    hashOutput = false;
    sha256 = "6985c538143c1208dcb1ac42cedad6ff52e267b47e5f970183a3e75125b43c2e";
  };

  buildInputs = [
    gmp
    mpfr
  ];

  doCheck = true;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = fileUrls "1.1.0";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "AD17 A21E F8AE D8F1 CC02  DBD9 F7D5 C9BF 765C 61E3";
      inherit (src) outputHashAlgo;
      outputHash = "6985c538143c1208dcb1ac42cedad6ff52e267b47e5f970183a3e75125b43c2e";
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
