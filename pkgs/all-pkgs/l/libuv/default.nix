{ stdenv
, autoconf
, automake
, fetchurl
, lib
, libtool
}:

let
  version = "1.30.1";
in
stdenv.mkDerivation rec {
  name = "libuv-${version}";

  src = fetchurl {
    url = "https://dist.libuv.org/dist/v${version}/libuv-v${version}.tar.gz";
    multihash = "QmbCWbJ7AqvmpPrqbgf2rHz7z619E6MhoB7ut9Jq431Bdq";
    hashOutput = false;
    sha256 = "468316fa841d114114f167b45d1f43d46a2a1852d8464336a4abbbf5b88b478b";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sign") src.urls;
        pgpKeyFingerprint = "AED6 E2A1 85EE B379 F174  76D2 E012 D07A D0E3 CC30";
      };
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
