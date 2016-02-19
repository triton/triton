{ stdenv, fetchurl, gettext, coreutils }:

stdenv.mkDerivation rec {
  name = "sharutils-4.15.2";

  src = fetchurl {
    url = "mirror://gnu/sharutils/${name}.tar.xz";
    sha256 = "16isapn8f39lnffc3dp4dan05b7x6mnc76v6q5nn8ysxvvvwy19b";
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
