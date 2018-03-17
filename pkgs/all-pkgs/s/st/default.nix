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
  name = "st-0.7";

  src = fetchurl {
    url = "https://dl.suckless.org/st/${name}.tar.gz";
    multihash = "QmV1FssAdXN44hWi4QjWp5GLn5ZqwqnvBjJ8JRNayMRi5Z";
    sha256 = "f7870d906ccc988926eef2cc98950a99cc78725b685e934c422c03c1234e6000";
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
