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
  name = "spectrwm-2019-07-25";

  src = fetchFromGitHub {
    version = 6;
    owner = "conformal";
    repo = "spectrwm";
    rev = "ff1909e7f4fe1fdf41ac0e428682b42a89040627";
    sha256 = "f1d3bac6e2976371a412e686321eaabc9897ab43be96ceb90c0c7b9c0c7e77d3";
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
