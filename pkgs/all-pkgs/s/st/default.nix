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
  name = "st-0.8.1";

  src = fetchurl {
    url = "https://dl.suckless.org/st/${name}.tar.gz";
    multihash = "QmTsbtodzbmPovWDFiaMF8Z9oCVUBVPAZD4BXvJYNVxRxN";
    sha256 = "c4fb0fe2b8d2d3bd5e72763e80a8ae05b7d44dbac8f8e3bb18ef0161c7266926";
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
