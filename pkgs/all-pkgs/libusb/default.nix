{ stdenv
, fetchurl

, udev ? null
}:

with {
  inherit (stdenv)
    isLinux;
  inherit (stdenv.lib)
    enFlag
    optional;
};

stdenv.mkDerivation rec {
  name = "libusb-1.0.20";

  src = fetchurl {
    url = "mirror://sourceforge/libusb/${name}.tar.bz2";
    sha256 = "1zzp6hc7r7m3gl6zjbmzn92zkih4664cckaf49l1g5hapa8721fb";
  };

  buildInputs = [ ]
    ++ optional isLinux udev;

  configureFlags = [
    "--disable-maintainer-mode"
    (enFlag "udev" (udev != null) null)
    #"--enable-timerfd"
    "--enable-log"
    "--disable-debug-log"
    "--enable-system-log"
    "--disable-examples-build"
    "--disable-tests-build"
  ];

  NIX_LDFLAGS = [ ]
    ++ optional isLinux "-lgcc_s";

  # Fails to correctly order objects
  parallelBuild = false;

  meta = with stdenv.lib; {
    description = "Userspace access to USB devices";
    homepage = http://www.libusb.info;
    license = licenses.lgpl21;
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
