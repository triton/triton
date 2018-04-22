{ stdenv
, fetchurl
, lib
}:

let
  channel = "0.1";
  version = "${channel}.46";
in
stdenv.mkDerivation rec {
  name = "babl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/babl/${channel}/${name}.tar.bz2";
    multihash = "QmcvoY76U9HmDpP8uPxF7SRec7cybphf7Vt8wfWrSiPstU";
    hashOutput = false;
    sha256 = "bbc2403b1badf8014ec42200e65d7b1f46e68e627c33c6242fa31ac5dc869e5b";
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
