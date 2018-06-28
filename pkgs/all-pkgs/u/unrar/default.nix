{ stdenv
, fetchurl
, lib
}:

let
  version = "5.6.5";
in
stdenv.mkDerivation rec {
  name = "unrar-${version}";

  src = fetchurl {
    url = "https://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    multihash = "QmYcE2AQasEnpnBxcqEk3HFz4Ae1xMXL2FxKMt54tXGzYN";
    sha256 = "eba36a421bf41491818dee9507d934064622bc0bd9db6bbb8422a4706f200898";
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
