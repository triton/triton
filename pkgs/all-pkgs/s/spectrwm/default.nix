{ stdenv
, fetchpatch
, fetchurl
, makeWrapper

, dmenu
, fontconfig
, freetype
, xorg
}:

let
  inherit (stdenv.lib)
    replaceStrings;

  replace = v: replaceStrings ["."] ["_"] v;

  version = "2.7.2";
in

stdenv.mkDerivation rec {
  name = "spectrwm-${version}";

  src = fetchurl {
    url = "https://github.com/conformal/spectrwm/archive/"
        + "SPECTRWM_${replace version}.tar.gz";
    sha256 = "23a5b306c5cdfda05eba365b652eca34e87f0b4317c7ff8059813adaa1c55afb";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    dmenu
    fontconfig
    freetype
    xorg.libX11
    xorg.libxcb
    xorg.libXcursor
    xorg.libXft
    xorg.libXrandr
    xorg.libXrender
    xorg.libXt
    xorg.libXtst
    xorg.randrproto
    xorg.renderproto
    xorg.xcbutil
    xorg.xcbutilkeysyms
    xorg.xcbutilwm
    xorg.xproto
  ];

  postUnpack = ''
    sourceRoot="$sourceRoot/linux"
  '';

  postPatch = 
    /* Fix freetype path */ ''
      sed -i Makefile \
        -e 's,/usr/include/freetype2,${freetype}/include/freetype,'
    '' +
    /* Fix libswmhack.so path */ ''
      sed -i ../spectrwm.c \
        -e "s,/usr/local/lib/libswmhack.so,$out/lib/libswmhack.so,"
    '';

  preConfigure = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  preFixup = ''
    wrapProgram $out/bin/spectrwm \
      --prefix 'PATH' : "${dmenu}/bin"
  '';

  meta = with stdenv.lib; {
    description = "A tiling window manager";
    homepage = https://github.com/conformal/spectrwm;
    license = licenses.isc;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
