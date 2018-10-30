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
  name = "spectrwm-2018-09-09";

  src = fetchFromGitHub {
    version = 6;
    owner = "conformal";
    repo = "spectrwm";
    rev = "b365987d3871d587663ad9204880df0504b31f72";
    sha256 = "3d778eeae78bd62f6bba55bc1e0a0723ba937a4ca485782b2dd25b1dd9d5883b";
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
