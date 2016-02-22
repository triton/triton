{ stdenv
, fetchurl
, gmp
, mpfr
}:

stdenv.mkDerivation rec {
  name = "libmpc-${version}";
  version = "1.0.3";

  src = fetchurl {
    url = "http://www.multiprecision.org/mpc/download/mpc-${version}.tar.gz";
    sha256 = "1hzci2zrrd7v3g1jk35qindq05hbl0bhjcyyisq9z209xb3fqzb1";
  };

  buildInputs = [
    gmp
    mpfr
  ];

  doCheck = true;

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
