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
  name = "spectrwm-2016-12-09";

  src = fetchFromGitHub {
    version = 2;
    owner = "conformal";
    repo = "spectrwm";
    rev = "2646d004bf17fb42799b887b4781a28de4c8bfb9";
    sha256 = "cc331269543ab8b0b2018ec7be549e0856738e1e2eeb8787280079fe7d225c86";
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
