{ stdenv
, fetchurl
, lib
}:

let
  version = "5.6.4";
in
stdenv.mkDerivation rec {
  name = "unrar-${version}";

  src = fetchurl {
    url = "https://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    multihash = "QmX4jmEHAUJT5ZKBQqZCcgqQSEhDMCWxLHoxMjGYmZVrgn";
    sha256 = "9335d2201870f2034007c04be80e00f1dc23932cb88b329d55c76134e6ba49fe";
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
