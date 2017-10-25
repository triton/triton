{ stdenv
, fetchpatch
, fetchFromGitHub
, lib
, makeWrapper

, fontconfig
, freetype
, libx11
, libxcb
, libxcursor
, libxft
, libxrandr
, libxrender
, libxt
#, libxtst
, randrproto
, renderproto
, which
, xorg
, xproto
}:

stdenv.mkDerivation rec {
  name = "spectrwm-2017-10-03";

  src = fetchFromGitHub {
    version = 2;
    owner = "conformal";
    repo = "spectrwm";
    rev = "81a78469359435f1cb9f38632aafad1cf8833640";
    sha256 = "cbac32e175ef3a4616d20141bdf7b6436a6782cd75dca0dccbc08b9445713d7d";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    fontconfig
    freetype
    libx11
    libxcb
    libxcursor
    libxft
    libxrandr
    libxrender
    libxt
    #libxtst
    xorg.libXtst
    randrproto
    renderproto
    xorg.xcbutil
    xorg.xcbutilkeysyms
    xorg.xcbutilwm
    xproto
  ];

  postUnpack = ''
    srcRoot="$sourceRoot/linux"
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
      --prefix 'PATH' : "${which}/bin"
  '';

  meta = with lib; {
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
