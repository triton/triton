{ stdenv
, fetchurl
}:

let
  version = "5.5.4";
in
stdenv.mkDerivation rec {
  name = "unrar-${version}";

  src = fetchurl {
    url = "http://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    multihash = "QmRuPBTpAaVSWDdWAYufXLzPE7UgTbCCajAB9dPDjmoFKc";
    sha256 = "c8217d311c8b3fbbd00737721f8d43d2b306192e1e39d7a858dcb714b2853517";
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
