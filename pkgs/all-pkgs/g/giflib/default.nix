{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "giflib-5.2.1";

  src = fetchurl {
    url = "mirror://sourceforge/giflib/${name}.tar.gz";
    sha256 = "31da5562f44c5f15d63340a09a4fd62b48c45620cd302f77a6d9acf0077879bd";
  };

  preBuild = ''
    makeFlagsArray+=(PREFIX="$out")
  '';

  meta = with lib; {
    description = "A library for reading and writing gif images";
    license = licenses.mit;
    maintainers = with stdenv.lib.maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
