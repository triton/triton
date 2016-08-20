{ stdenv
, fetchurl
}:

let
  version = "5.4.5";
in
stdenv.mkDerivation rec {
  name = "unrar-${version}";

  src = fetchurl {
    url = "http://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    multihash = "QmaqfJQwrnMAVu3XDQF5PYhud7nxuWVDHJv7mw2b21trqU";
    sha256 = "e470c584332422893fb52e049f2cbd99e24dc6c6da971008b4e2ae4284f8796c";
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
