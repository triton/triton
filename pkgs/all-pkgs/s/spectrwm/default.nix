{ stdenv
, fetchpatch
, fetchFromGitHub
, makeWrapper

, dmenu
, fontconfig
, freetype
, xorg
}:

stdenv.mkDerivation rec {
  name = "spectrwm-2016-06-26";

  src = fetchFromGitHub {
    owner = "conformal";
    repo = "spectrwm";
    rev = "9d338b286b1a2a240f92070bf1e95dc6f4c27bea";
    sha256 = "783d78d6fb84be0995db898c0e81a425f73a546537662cf08a88718049e0987c";
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
    /* Remove legacy scrotwm alias */ ''
      sed -i Makefile \
        -e '/scrotwm/d';
    '';

  configurePhase = ":";

  preBuild = ''
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
