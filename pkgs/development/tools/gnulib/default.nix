{ stdenv, fetchgit }:

stdenv.mkDerivation {
  name = "gnulib-0.1-357-gffe6467";

  phases = ["unpackPhase" "installPhase"];

  src = fetchgit {
    url = "http://git.savannah.gnu.org/r/gnulib.git";
    rev = "92b60e61666f008385d9b7f7443da17c7a44d1b1";
    sha256 = "082k4ng7yax68if4byk4bqvs8s86gr1wvn6i8vzya6hi8vmyvflk";
  };

  installPhase = "mkdir -p $out; mv * $out/";

  meta = {
    homepage = "http://www.gnu.org/software/gnulib/";
    description = "central location for code to be shared among GNU packages";
    license = stdenv.lib.licenses.gpl3Plus;
  };
}
