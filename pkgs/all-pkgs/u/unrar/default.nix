{ stdenv
, fetchurl
, lib
}:

let
  version = "5.6.1";
in
stdenv.mkDerivation rec {
  name = "unrar-${version}";

  src = fetchurl {
    url = "https://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    multihash = "Qme3Zq2AMQQdtQ4hJUv81zCKmjbUkpf8Hx6dGYHpayrYVC";
    sha256 = "67c339dffa95f6c1bedcca40045e99de5852919dbfaa06e4a9c8f18cd5064e70";
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
