{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "giflib-5.1.9";

  src = fetchurl {
    url = "mirror://sourceforge/giflib/${name}.tar.gz";
    sha256 = "36ccab06aa43e5d608cdd74902f89c47fd55c348009798434ba5798967454057";
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
