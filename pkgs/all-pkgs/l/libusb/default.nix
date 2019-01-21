{ stdenv
, fetchurl

, systemd_lib
}:

let
  inherit (stdenv.lib)
    optional;

  version = "1.0.22";
in
stdenv.mkDerivation rec {
  name = "libusb-${version}";

  src = fetchurl {
    url = "https://github.com/libusb/libusb/releases/download/v${version}/"
      + "${name}.tar.bz2";
    sha256 = "75aeb9d59a4fdb800d329a545c2e6799f732362193b465ea198f2aa275518157";
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
