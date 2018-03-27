{ stdenv
, fetchurl
, lib
}:

let
  channel = "0.1";
  version = "${channel}.44";
in
stdenv.mkDerivation rec {
  name = "babl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/babl/${channel}/${name}.tar.bz2";
    multihash = "QmVbnwex9VuX31AeFJRf7Lyg2JnJL1ATJV3tdRP6D3qXhm";
    hashOutput = false;
    sha256 = "f463fda0dec534c442234d1c374ea5d19abe0da942e11c9c5092dcc6b30cde7d";
  };

  configureFlags = [
    "--disable-maintainer-mode"
  ];

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
