{ stdenv
, lib
, fetchurl
}:

let
  version = "0.12.3";
in
stdenv.mkDerivation rec {
  name = "riot-${version}";

  src = fetchurl {
    url = "https://github.com/vector-im/riot-web/releases/download/v${version}/riot-v${version}.tar.gz";
    sha256 = "631188da5af2ca72c2e4d1296b1901a53e9807a7a493468b8ef1e7a46c4e33ed";
  };

  installPhase = ''
    mkdir -p "$out"/share/riot
    mv * "$out"/share/riot
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
