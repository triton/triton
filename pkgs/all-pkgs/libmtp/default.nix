{ stdenv
, fetchurl

, libusb_1
}:

stdenv.mkDerivation rec {
  name = "libmtp-1.1.11";

  src = fetchurl {
    url = "mirror://sourceforge/libmtp/${name}.tar.gz";
    multihash = "QmWzAD93fuGJiAQ5nH2N74RnKLfQLNZrYLcmH3JmitgWvu";
    allowHashOutput = false;
    sha256 = "15d96dff79a4f7ad14338894a4096d4ac584c6ad25fdcca955bc4726303287e9";
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
      pgpKeyFingerprint = "D33B C5C3 C0CC 59B6 3989  D77B EA7B F397 0175 623E";
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
