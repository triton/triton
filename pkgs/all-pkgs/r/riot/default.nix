{ stdenv
, lib
, fetchurl
}:

let
  version = "0.16.0";
in
stdenv.mkDerivation rec {
  name = "riot-${version}";

  src = fetchurl {
    url = "https://github.com/vector-im/riot-web/releases/download/v${version}/riot-v${version}.tar.gz";
    hashOutput = false;
    sha256 = "b55c5c074069a26fd3cff1f38ae34d79d4fc6fa1d66c68d23ce542ea0a8c80da";
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
