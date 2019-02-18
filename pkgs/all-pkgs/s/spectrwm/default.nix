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
, libxtst
, which
, xorg
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "spectrwm-2019-01-20";

  src = fetchFromGitHub {
    version = 6;
    owner = "conformal";
    repo = "spectrwm";
    rev = "e2c42a9de99788a12e110ec7bda83d151bd0d826";
    sha256 = "d43846c9a87d5981030986b9151acff1d0ed75913c657abf0694ee5a8c968ca0";
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
    libxtst
    xorg.xcbutil
    xorg.xcbutilkeysyms
    xorg.xcbutilwm
    xorgproto
  ];

  postUnpack = ''
    srcRoot="$srcRoot/linux"
  '';

  postPatch = /* Remove legacy scrotwm alias */ ''
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
