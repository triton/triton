{ stdenv
, fetchurl
, lib
}:

let
  channel = "0.1";
  version = "${channel}.54";
in
stdenv.mkDerivation rec {
  name = "babl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/babl/${channel}/${name}.tar.bz2";
    multihash = "QmS4bqtTZfEobQGaxrXBZF9sYBGxmvT4W692jTc5f5NUfZ";
    hashOutput = false;
    sha256 = "40f714a0fc043e16ac05c670f39e4db0d0d923480d21952fb0569686479ef76c";
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
