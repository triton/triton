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
, randrproto
, renderproto
, which
, xorg
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "spectrwm-2017-10-14";

  src = fetchFromGitHub {
    version = 5;
    owner = "conformal";
    repo = "spectrwm";
    rev = "ea3e6da62247572e92c4ba00f70eab73f6254adf";
    sha256 = "de6c2c7d9931d228a8ac0827c6a484b62ed8e1b990f75806af42419f5a242015";
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
