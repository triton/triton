{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "unrar-${version}";
  version = "5.4.4";

  src = fetchurl {
    url = "http://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    sha256 = "556b65d61164b018c4a3ce10e6290b16f4d042a603f6a4e17f74b19ac25d2d83";
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
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
