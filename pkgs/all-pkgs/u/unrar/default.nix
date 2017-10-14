{ stdenv
, fetchurl
, lib
}:

let
  version = "5.5.8";
in
stdenv.mkDerivation rec {
  name = "unrar-${version}";

  src = fetchurl {
    url = "http://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    multihash = "QmTwKJo3Kps34pQW71wU2SYhNnFYjxDjksUmjSq482Daq6";
    sha256 = "9b66e4353a9944bc140eb2a919ff99482dd548f858f5e296d809e8f7cdb2fcf4";
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
