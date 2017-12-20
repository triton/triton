{ stdenv
, fetchurl
}:

let
  major = "0.1";
  patch = "38";
  version = "${major}.${patch}";
in
stdenv.mkDerivation rec {
  name = "babl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/babl/${major}/${name}.tar.bz2";
    multihash = "QmZdN7aK3sSb1u8xRNZ7J4XADGc25XfGZesK5djNgx7vKM";
    hashOutput = false;
    sha256 = "a0f9284fcade0377d5227f73f3bf0c4fb6f1aeee2af3a7d335a90081bf5fee86";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha1Urls = map (n: "${n}/../SHA1SUMS") src.urls;
      sha256Urls = map (n: "${n}/../SHA256SUMS") src.urls;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
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
