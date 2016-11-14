{ stdenv
, fetchurl

, systemd_lib
}:

let
  inherit (stdenv.lib)
    optional;

  version = "1.0.21";
in
stdenv.mkDerivation rec {
  name = "libusb-${version}";

  src = fetchurl {
    url = "https://github.com/libusb/libusb/releases/download/v${version}/"
      + "${name}.tar.bz2";
    sha256 = "7dce9cce9a81194b7065ee912bcd55eeffebab694ea403ffb91b67db66b1824b";
  };

  buildInputs = [
    systemd_lib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-udev"
    "--disable-usbdk"
    #"--enable-timerfd"
    "--enable-log"
    "--disable-debug-log"
    "--enable-system-log"
    "--disable-examples-build"
    "--disable-tests-build"
  ];

  NIX_LDFLAGS = [
    "-lgcc_s"
  ];

  meta = with stdenv.lib; {
    description = "Userspace access to USB devices";
    homepage = http://www.libusb.info;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
