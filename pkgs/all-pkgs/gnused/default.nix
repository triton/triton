{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "gnused-${version}";
  version = "4.2.2";

  src = fetchurl {
    url = "mirror://gnu/sed/sed-${version}.tar.bz2";
    sha256 = "f048d1838da284c8bc9753e4506b85a1e0cc1ea8999d36f6995bcb9460cddbd7";
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/sed/;
    description = "GNU sed, a batch stream editor";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
