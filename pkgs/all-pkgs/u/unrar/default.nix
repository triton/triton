{ stdenv
, fetchurl
, lib
}:

let
  version = "5.6.3";
in
stdenv.mkDerivation rec {
  name = "unrar-${version}";

  src = fetchurl {
    url = "https://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    multihash = "Qmeutj44mTUK6bXfen8hwmwpRwAosh7QBy3cqQw2EvZc36";
    sha256 = "c590e70a745d840ae9b9f05ba6c449438838c8280d76ce796a26b3fcd0a1972e";
  };

  setupHook = ./setup-hook.sh;

  preBuild = ''
    makeFlags+=("DESTDIR=$out")
  '';

  meta = with lib; {
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
