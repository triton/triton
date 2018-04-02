{ stdenv
, fetchurl
, lib
}:

let
  version = "5.6.2";
in
stdenv.mkDerivation rec {
  name = "unrar-${version}";

  src = fetchurl {
    url = "https://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    multihash = "QmTSwttKCqWHDE8zrP9YjWvX1v1wZ2dehRApxUKstXouLw";
    sha256 = "ce048094764b2377dd60802359c74f03528b6d7defd808cd584443c5fd2de948";
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
