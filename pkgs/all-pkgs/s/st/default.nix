{ stdenv
, fetchurl
, lib
, writeText

, freetype
, fontconfig
, libx11
, libxext
, libxft
, libxrender
, ncurses
, xorgproto

, config ? null
, configFile ? null
}:

assert config != null -> configFile == null;

let
  inherit (lib)
    optionalString;

  configFile' =
    if configFile != null then
      configFile
    else if config != null then
      writeText "st-config.def.h" config
    else
      null;
in
stdenv.mkDerivation rec {
  name = "st-0.8.2";

  src = fetchurl {
    url = "https://dl.suckless.org/st/${name}.tar.gz";
    multihash = "Qmb2bAu2eGhYDMaVMK4uP77YNCxTZYXRGni5LUbXwCW3QC";
    sha256 = "aeb74e10aa11ed364e1bcc635a81a523119093e63befd2f231f8b0705b15bf35";
  };

  preBuild = optionalString (configFile' != null) ''
    cp ${configFile'} config.def.h
  '';

  buildInputs = [
    freetype
    fontconfig
    libx11
    libxext
    libxft
    libxrender
    ncurses
    xorgproto
  ];

  preInstall = ''
    export TERMINFO="$out/share/terminfo"
    installFlagsArray+=("PREFIX=$out")
  '';

  meta = with lib; {
    homepage = http://st.suckless.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
