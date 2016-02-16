{ stdenv, fetchurl, gettext, coreutils }:

stdenv.mkDerivation rec {
  name = "sharutils-4.11.1";

  src = fetchurl {
    url = "mirror://gnu/sharutils/${name}.tar.bz2";
    sha256 = "1mallg1gprimlggdisfzdmh1xi676jsfdlfyvanlcw72ny8fsj3g";
  };

  # GNU Gettext is needed on non-GNU platforms.
  nativeBuildInputs = [ gettext coreutils ];

  doCheck = true;

  meta = {
    description = "Tools for remote synchronization and `shell archives'";
    homepage = http://www.gnu.org/software/sharutils/;
    license = stdenv.lib.licenses.gpl3Plus;
    platforms = stdenv.lib.platforms.all;
  };
}
