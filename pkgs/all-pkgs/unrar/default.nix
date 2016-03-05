{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "unrar-${version}";
  version = "5.3.11";

  src = fetchurl {
    url = "http://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    sha256 = "0qw77gvr57azjbn76cjlm4sv1hf2hh90g7n7n33gfvlpnbs7mf3p";
  };

  preBuild = ''
    export buildFlags="CXX=$CXX"
  '';

  installPhase = ''
    installBin unrar

    mkdir -p $out/share/doc/unrar
    cp acknow.txt license.txt \
        $out/share/doc/unrar
  '';

  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; {
    description = "Utility for RAR archives";
    homepage = http://www.rarlab.com/;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
