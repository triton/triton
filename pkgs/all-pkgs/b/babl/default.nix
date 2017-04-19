{ stdenv
, fetchurl
}:

let
  major = "0.1";
  patch = "24";
  version = "${major}.${patch}";
in
stdenv.mkDerivation rec {
  name = "babl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/babl/${major}/${name}.tar.bz2";
    multihash = "QmU1BatiGMYAA6tEryzsvPmdXfUkLV5awxcY491QaBoXXx";
    hashOutput = false;
    sha256 = "472bf1acdde5bf076e6d86f3004eea4e9b007b1377ab305ebddec99994f29d0b";
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
