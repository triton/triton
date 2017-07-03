{ stdenv
, fetchurl
}:

let
  version = "5.5.6";
in
stdenv.mkDerivation rec {
  name = "unrar-${version}";

  src = fetchurl {
    url = "http://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    multihash = "QmbBJExFRM2UQ2rbAqosTU6CMFQyiXbAJhkA9CFSyqgNMX";
    sha256 = "68a9d8f40c709b883bb15b21a9811907e56a07411d90aeaa992622ed9cf128c0";
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
