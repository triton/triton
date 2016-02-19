{ stdenv
, fetchurl

, xorg
}:

stdenv.mkDerivation rec {
  name = "spectrwm-${version}";
  version = "2.7.2";

  src = fetchurl {
    url = "https://github.com/conformal/spectrwm/archive/SPECTRWM_2_7_2.tar.gz";
    sha256 = "1yssqnhxlfl1b60gziqp8c5pzs1lr8p6anrnp9ga1zfdql3b7993";
  };


  buildInputs = [
    xorg.libX11
    xorg.libxcb
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXft
    xorg.libXt
    xorg.xcbutil
    xorg.xcbutilcursor
    xorg.xcbutilkeysyms
    xorg.xcbutilwm
  ];

  sourceRoot = "spectrwm-SPECTRWM_2_7_2/linux";
  makeFlags="PREFIX=$(out)";
  installPhase = "PREFIX=$out make install";

  meta = with stdenv.lib; {
    description = "A tiling window manager";
    homepage    = "https://github.com/conformal/spectrwm";
    maintainers = with maintainers; [ ];
    license     = licenses.isc;
    platforms   = platforms.all;
  };

}
