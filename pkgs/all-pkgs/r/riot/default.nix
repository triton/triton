{ stdenv
, lib
, fetchurl
}:

let
  version = "0.15.7";
in
stdenv.mkDerivation rec {
  name = "riot-${version}";

  src = fetchurl {
    url = "https://github.com/vector-im/riot-web/releases/download/v${version}/riot-v${version}.tar.gz";
    hashOutput = false;
    sha256 = "9089f5994f710b97a91754cd7b7721684467d8bdbe7e38fc4a8b685b19164a27";
  };

  installPhase = ''
    mkdir -p "$out"/share/riot
    mv * "$out"/share/riot
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "6FEB 6F83 D48B 9354 7E7D  FEDE E019 6452 48E8 F4A1";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
