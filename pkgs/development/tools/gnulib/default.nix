{ stdenv
, fetchgit
}:

stdenv.mkDerivation {
  name = "gnulib-2016-06-20";

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  src = fetchgit {
    url = "http://git.savannah.gnu.org/r/gnulib.git";
    rev = "0ba497e828236d81d79fd0bcbdca0fb5c37e4525";
    sha256 = "1w4slirrysbhq998c9b10v2lmkqrdm354n2k0irfqdhn2zp372ha";
  };

  installPhase = ''
    mkdir -p $out
    mv * $out
  '';

  meta = {
    homepage = "http://www.gnu.org/software/gnulib/";
    description = "central location for code to be shared among GNU packages";
    license = stdenv.lib.licenses.gpl3Plus;
  };
}
