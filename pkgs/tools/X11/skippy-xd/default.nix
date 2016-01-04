{stdenv, fetchgit, libjpeg, giflib, xorg
}:
let
  buildInputs = [
    xorg.xproto xorg.libX11 xorg.libXft xorg.libXcomposite xorg.libXdamage xorg.libXext xorg.xextproto 
    xorg.libXinerama libjpeg giflib
  ];
in
stdenv.mkDerivation rec {
  version = "git-2015-03-01";
  name = "skippy-xd-${version}";
  inherit buildInputs;
  src = fetchgit {
    url = "https://github.com/richardgv/skippy-xd/";
    rev = "397216ca67";
    sha256 = "19lvy5888j7rl52dsxv1wwxxijdlk8d7qn1zzzy0b8wvqknhxypm";
  };
  makeFlags = ["PREFIX=$(out)"];
  preInstall = ''
    sed -e "s@/etc/xdg@$out&@" -i Makefile
  '';
  meta = {
    inherit version;
    description = ''Expose-style compositing-based standalone window switcher'';
    license = stdenv.lib.licenses.gpl2Plus ;
    maintainers = [stdenv.lib.maintainers.raskin];
    platforms = stdenv.lib.platforms.linux;
  };
}
