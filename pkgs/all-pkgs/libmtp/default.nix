{ stdenv
, fetchurl

, libusb_1
}:

stdenv.mkDerivation rec {
  name = "libmtp-1.1.11";

  src = fetchurl {
    url = "mirror://sourceforge/libmtp/${name}.tar.gz";
    multihash = "QmW9zJhmHV6JiAd9Ee6a2iB9z7ueybnch4nGamhNG1ifQh";
    sha256 = "0183r5is1z6qmdbj28ryz8k8dqijll4drzh8lic9xqig0m68vvhy";
  };

  buildInputs = [
    libusb_1
  ];

  preConfigure = ''
    configureFlagsArray+=("--with-udev=$out/lib/udev")
  '';

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
