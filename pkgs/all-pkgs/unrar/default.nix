{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "unrar-${version}";
  version = "5.4.2";

  src = fetchurl {
    url = "http://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    sha256 = "d91d5fa8abdbac60b3e2b7317cc1451a2b38c550adee977b847f22594c53f1bd";
  };

  preBuild = ''
    makeFlags+=(
      DESTDIR=$out
    )
  '';

  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; {
    description = "Utility for RAR archives";
    homepage = http://www.rarlab.com/;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
