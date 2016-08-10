{ stdenv
, fetchgit
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
  name = "st-2016-03-28";
  
  src = fetchgit {
    url = "git://git.suckless.org/st";
    rev = "39964614b742c4ec98a326762d98470cb987a45b";
    sha256 = "0vi3i43vzdc5333mrai684ay6sfm05mgaq3gqzzydc9mbal6319i";
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
