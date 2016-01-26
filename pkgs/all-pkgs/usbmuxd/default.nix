{ stdenv
, fetchurl

, libimobiledevice
, libplist
, libusb
}:

with {
  inherit (stdenv.lib)
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "usbmuxd-${version}";
  version = "1.1.0";

  src = fetchurl {
    url = "http://www.libimobiledevice.org/downloads/${name}.tar.bz2";
    sha256 = "0bdlc7a8plvglqqx39qqampqm6y0hcdws76l9dffwl22zss4i29y";
  };

  buildInputs = [
    libimobiledevice
    libplist
    libusb
  ];

  configureFlags = [
    "--with-udevrulesdir=$(out)/lib/udev/rules.d"
    "--without-systemd"
    "--without-systemdsystemunitdir"
  ];

  meta = with stdenv.lib; {
    description = "USB multiplex daemon for Apple iPhone/iPod Touch devices";
    homepage = http://www.libimobiledevice.org/;
    # http://marcansoft.com/blog/iphonelinux/usbmuxd/
    license = with licenses; [
      gpl2
      gpl3
      lgpl21Plus
    ];
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
