{ stdenv
, autoconf
, automake
, fetchurl
, lib
, libtool
}:

let
  version = "1.35.0";
in
stdenv.mkDerivation rec {
  name = "libuv-${version}";

  src = fetchurl {
    url = "https://dist.libuv.org/dist/v${version}/libuv-v${version}.tar.gz";
    multihash = "QmZ7GEGFkCZy8nDDY1wbZusoTMjAHdaJ4kWUeWsL1guhbJ";
    hashOutput = false;
    sha256 = "0e947d02543ad6e6ef11c19ad1587afc57c95ff31a18f57413490faeaaab4604";
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
        pgpKeyFingerprints = [
          "AED6 E2A1 85EE B379 F174  76D2 E012 D07A D0E3 CC30"
          "5735 3E0D BDAA A7E8 39B6  6A1A FF47 D5E4 AD8B 4FDC"
        ];
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
