{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "sharutils-4.15.2";

  src = fetchurl {
    url = "mirror://gnu/sharutils/${name}.tar.xz";
    sha256 = "16isapn8f39lnffc3dp4dan05b7x6mnc76v6q5nn8ysxvvvwy19b";
  };

  meta = with stdenv.lib; {
    description = "Tools for remote synchronization and `shell archives'";
    homepage = http://www.gnu.org/software/sharutils/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
