{ stdenv
, autoconf
, automake
, fetchurl
, lib
, libtool
}:

let
  version = "1.32.0";
in
stdenv.mkDerivation rec {
  name = "libuv-${version}";

  src = fetchurl {
    url = "https://dist.libuv.org/dist/v${version}/libuv-v${version}.tar.gz";
    multihash = "QmVCerwwfx8m4Wo7pGpepjGUewfJ9gAaJWs6KKREJbma5z";
    hashOutput = false;
    sha256 = "203927683d53d1b82eee766c8ffecfa8ed0e392679c15d5ad3a23504eda0ed1f";
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
