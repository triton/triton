{ stdenv
, fetchurl
}:

let
  version = "5.5.3";
in
stdenv.mkDerivation rec {
  name = "unrar-${version}";

  src = fetchurl {
    url = "http://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    multihash = "QmVnLhfQGUkNjmiUYyUEJHs4Fg2wDWzpKb1mePBZNqTF4x";
    sha256 = "d1d9ef4a9247db088f825666de8f8bb69006d8d8b0e004ff366b3e04c103a2b3";
  };

  setupHook = ./setup-hook.sh;

  preBuild = ''
    makeFlags+=("DESTDIR=$out")
  '';

  meta = with stdenv.lib; {
    description = "Utility for RAR archives";
    homepage = http://www.rarlab.com/;
    license = licenses.unfreeRedistributable; # unRAR
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
