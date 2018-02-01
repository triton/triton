{ stdenv
, fetchurl
, lib
}:

let
  channel = "0.1";
  version = "${channel}.42";
in
stdenv.mkDerivation rec {
  name = "babl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/babl/${channel}/${name}.tar.bz2";
    multihash = "QmQNUhy9hHMNhTvy7xrw9hiJkMprqg3KGbY2512PRD4hSg";
    hashOutput = false;
    sha256 = "6859aff3d7210d1f0173297796da4581323ef61e6f0c1e1c8f0ebb95a47787f1";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha1Urls = map (n: "${n}/../SHA1SUMS") src.urls;
      sha256Urls = map (n: "${n}/../SHA256SUMS") src.urls;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "Image pixel format conversion library";
    homepage = http://gegl.org/babl/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
