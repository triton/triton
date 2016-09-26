{ stdenv
, fetchgit
}:

stdenv.mkDerivation {
  name = "gnulib-2016-09-24";

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  src = fetchgit {
    version = 2;
    url = "http://git.savannah.gnu.org/r/gnulib.git";
    rev = "85854baba34817be27d9ad3b6c013fde9fb08236";
    sha256 = "0zy86k347d6h4bjvb2s1vsp8i8a1gliz4nziqylpz1jmcmz27km4";
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
