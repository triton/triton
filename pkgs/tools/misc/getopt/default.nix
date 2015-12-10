{ stdenv, fetchurl, gettext }:

stdenv.mkDerivation rec {
  name = "getopt-1.1.6";

  src = fetchurl {
    url = "http://frodo.looijaard.name/system/files/software/getopt/${name}.tar.gz";
    sha256 = "1zn5kp8ar853rin0ay2j3p17blxy16agpp8wi8wfg4x98b31vgyh";
  };

  nativeBuildInputs = [ gettext ];

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  meta = with stdenv.lib; {
    homepage = "http://frodo.looijaard.name/project/getopt";
    description = "a program to help shell scripts parse command-line parameters";
    license = licenses.gpl2;
    platforms = platforms.all;
  };
}
