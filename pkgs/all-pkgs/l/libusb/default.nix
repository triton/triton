{ stdenv
, fetchurl

, systemd_lib
}:

let
  inherit (stdenv.lib)
    optional;

  version = "1.0.23";
in
stdenv.mkDerivation rec {
  name = "libusb-${version}";

  src = fetchurl {
    url = "https://github.com/libusb/libusb/releases/download/v${version}/"
      + "${name}.tar.bz2";
    sha256 = "db11c06e958a82dac52cf3c65cb4dd2c3f339c8a988665110e0d24d19312ad8d";
  };

  buildInputs = [
    systemd_lib
  ];

  configureFlags = [
    "--enable-udev"
    "--enable-timerfd"
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
