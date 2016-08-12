{ stdenv
, fetchurl

, libusb_1
}:

stdenv.mkDerivation rec {
  name = "libmtp-1.1.12";

  src = fetchurl {
    url = "mirror://sourceforge/libmtp/${name}.tar.gz";
    multihash = "QmS2d3fXyGmNR9WxbpXwAhgvecKrcxYJ6CiXEiMnJmy41J";
    allowHashOutput = false;
    sha256 = "cdf59e816c6cda3e908a876c7fb42943f40b85669aea0029a1ca431c89afa1a0";
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

  meta = with stdenv.lib; {
    homepage = http://libmtp.sourceforge.net;
    description = "An implementation of Microsoft's Media Transfer Protocol";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
