{ stdenv
, fetchurl
, writeText

, freetype
, fontconfig
, ncurses
, xorg

, config ? null
, configFile ? null
}:

assert config != null -> configFile == null;

let
  inherit (stdenv.lib)
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
    url = "http://dl.suckless.org/st/${name}.tar.gz";
    multihash = "QmV1FssAdXN44hWi4QjWp5GLn5ZqwqnvBjJ8JRNayMRi5Z";
    sha256 = "f7870d906ccc988926eef2cc98950a99cc78725b685e934c422c03c1234e6000";
  };

  preBuild = optionalString (configFile' != null) ''
    cp ${configFile'} config.def.h
  '';
  
  buildInputs = [
    freetype
    fontconfig
    ncurses
    xorg.kbproto
    xorg.libX11
    xorg.libXext
    xorg.libXft
    xorg.libXrender
    xorg.renderproto
    xorg.xproto
  ];

  preInstall = ''
    export TERMINFO="$out/share/terminfo"
    installFlagsArray+=("PREFIX=$out")
  '';
    
  meta = with stdenv.lib; {
    homepage = http://st.suckless.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
