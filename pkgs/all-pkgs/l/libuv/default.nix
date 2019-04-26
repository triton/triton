{ stdenv
, autoconf
, automake
, fetchurl
, lib
, libtool
}:

let
  version = "1.28.0";
in
stdenv.mkDerivation rec {
  name = "libuv-${version}";

  src = fetchurl {
    url = "https://dist.libuv.org/dist/v${version}/libuv-v${version}.tar.gz";
    multihash = "QmY3TXXpw2duSbWX7uEPweZci6X1eMFu1nUqcPerCZcqrB";
    hashOutput = false;
    sha256 = "30af87a2d6052047192ec6460398f93716f8b71268367e08662a6ef7a27e06ad";
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
