{ stdenv
, fetchurl
, lib

, libusb_1
}:

let
  version = "1.1.13";
in
stdenv.mkDerivation rec {
  name = "libmtp-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libmtp/libmtp/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "494ee02fbfbc316aad75b93263dac00f02a4899f28cfda1decbbd6e26fda6d40";
  };

  buildInputs = [
    libusb_1
  ];

  preConfigure = ''
    configureFlagsArray+=("--with-udev=$out/lib/udev")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        "7C4A FD61 D8AA E757 0796  A517 2209 D690 2F96 9C95"
        "D33B C5C3 C0CC 59B6 3989  D77B EA7B F397 0175 623E"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "An implementation of Microsoft's Media Transfer Protocol";
    homepage = http://libmtp.sourceforge.net;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
