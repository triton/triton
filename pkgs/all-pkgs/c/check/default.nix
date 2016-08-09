{ stdenv
, fetchurl
}:

let
  version = "0.10.0";
in
stdenv.mkDerivation rec {
  name = "check-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/check/${version}/check-${version}.tar.gz";
    sha256 = "0lhhywf5nxl3dd0hdakra3aasl590756c9kmvyifb3vgm9k0gxgm";
  };

  meta = with stdenv.lib; {
    description = "Unit testing framework for C";
    homepage = http://check.sourceforge.net/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
