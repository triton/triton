{ stdenv
, fetchurl
, lib
}:

let
  channel = "0.1";
  version = "${channel}.58";
in
stdenv.mkDerivation rec {
  name = "babl-${version}";

  src = fetchurl {
    url = "https://download.gimp.org/pub/babl/${channel}/${name}.tar.bz2";
    multihash = "QmPodrJ41evFgg2YVHtNvJuZGuZJGqWETpSqXtV1q2jMMm";
    hashOutput = false;
    sha256 = "79c9ae576019b8459896014c8822471bb383414c9f99a1b2055e25b4538ced55";
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
