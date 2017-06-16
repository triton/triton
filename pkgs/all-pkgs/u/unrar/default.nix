{ stdenv
, fetchurl
}:

let
  version = "5.5.5";
in
stdenv.mkDerivation rec {
  name = "unrar-${version}";

  src = fetchurl {
    url = "http://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    multihash = "Qmd8Y1w4PCBaqRxV4VCV7cKJJuZMEFy9Ua2keGxhFEhTns";
    sha256 = "a4553839cb2f025d0d9c5633816a83a723e3938209f17620c8c15da06ed061ef";
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
