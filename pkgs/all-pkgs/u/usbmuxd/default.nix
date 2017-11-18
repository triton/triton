{ stdenv
, fetchurl
, lib

, libimobiledevice
, libplist
, libusb
}:

stdenv.mkDerivation rec {
  name = "usbmuxd-1.1.0";

  src = fetchurl {
    url = "http://www.libimobiledevice.org/downloads/${name}.tar.bz2";
    multihash = "QmY9sEX9b2pEYR3WbY3GTfsa4MEysyU7HA8PLvZdCkhWpQ";
    sha256 = "3e8948b4fe4250ee5c4bd41ccd1b83c09b8a6f5518a7d131a66fd38bd461b42d";
  };

  buildInputs = [
    libimobiledevice
    libplist
    libusb
  ];

  preConfigure = ''
    configureFlagsArray+=("--with-udevrulesdir=$out/lib/udev/rules.d")
  '';

  configureFlags = [
    "--without-systemd"
    "--without-systemdsystemunitdir"
  ];

  meta = with lib; {
    description = "USB multiplex daemon for Apple iPhone/iPod Touch devices";
    homepage = http://www.libimobiledevice.org/;
    # http://marcansoft.com/blog/iphonelinux/usbmuxd/
    license = with licenses; [
      gpl2
      gpl3
      lgpl21Plus
    ];
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
