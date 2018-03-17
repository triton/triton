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
  name = "st-0.8";

  src = fetchurl {
    url = "https://dl.suckless.org/st/${name}.tar.gz";
    multihash = "QmVXjDbXRA3jahZhb3xUghJfsyPCPn58TNAkNHMG6oEjYE";
    sha256 = "77353920d07d66c684a0f57ec37c2670c42fdc5c871d6382b701601cdc597576";
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
