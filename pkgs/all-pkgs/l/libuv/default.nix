{ stdenv
, autoconf
, automake
, fetchurl
, lib
, libtool
}:

let
  version = "1.26.0";
in
stdenv.mkDerivation rec {
  name = "libuv-${version}";

  src = fetchurl {
    url = "https://dist.libuv.org/dist/v${version}/libuv-v${version}.tar.gz";
    hashOutput = false;
    sha256 = "caf817a7fb7f3fd1a2fe1517c777327fa76f04b36afc46238ad609f0148014e7";
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
