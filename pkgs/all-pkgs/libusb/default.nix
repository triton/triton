{ stdenv
, fetchurl

, systemd_lib
}:

let
  inherit (stdenv.lib)
    optional;
in

stdenv.mkDerivation rec {
  name = "libusb-1.0.20";

  src = fetchurl {
    url = "mirror://sourceforge/libusb/${name}.tar.bz2";
    sha256 = "1zzp6hc7r7m3gl6zjbmzn92zkih4664cckaf49l1g5hapa8721fb";
  };

  buildInputs = [
    systemd_lib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-udev"
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

  # Fails to correctly order objects
  parallelBuild = false;

  meta = with stdenv.lib; {
    description = "Userspace access to USB devices";
    homepage = http://www.libusb.info;
    license = licenses.lgpl21;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
