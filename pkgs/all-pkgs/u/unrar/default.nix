{ stdenv
, fetchurl
, lib
}:

let
  version = "5.6.6";
in
stdenv.mkDerivation rec {
  name = "unrar-${version}";

  src = fetchurl {
    url = "https://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    multihash = "QmeBCvw4pA5o4TATDYUBCvnMp2txxLUnVmzmW5HQRqZxba";
    sha256 = "5dbdd3cff955c4bc54dd50bf58120af7cb30dec0763a79ffff350f26f96c4430";
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
