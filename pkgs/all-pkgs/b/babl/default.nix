{ stdenv
, fetchurl
, lib
}:

let
  channel = "0.1";
  version = "${channel}.56";
in
stdenv.mkDerivation rec {
  name = "babl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/babl/${channel}/${name}.tar.bz2";
    multihash = "QmUGTuLgr5xSWZWpzF5D3v3oVA3Rc6x8PKeqhHCueha2Gm";
    hashOutput = false;
    sha256 = "8ad26ca717ec3c74e261f454dd6bb316333a39fd1f87db4ac44706a860dc4d28";
  };

  configureFlags = [
    "--disable-maintainer-mode"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        sha1Urls = map (n: "${n}/../SHA1SUMS") src.urls;
        sha256Urls = map (n: "${n}/../SHA256SUMS") src.urls;
      };
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
