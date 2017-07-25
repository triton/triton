{ stdenv
, fetchurl
}:

let
  version = "5.5.7";
in
stdenv.mkDerivation rec {
  name = "unrar-${version}";

  src = fetchurl {
    url = "http://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    multihash = "QmT4j44RHb4R8YBqQQnsikYqWheUWhd6avCfHb7e7AQK3S";
    sha256 = "8aef0a0d91bf9c9ac48fab8a26049ac7ac49907e75a2dcbd511a4ba375322d8f";
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
