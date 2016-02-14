{ stdenv
, fetchurl

, libusb
}:

stdenv.mkDerivation rec {
  name = "libusb-compat-0.1.5";

  src = fetchurl {
    url = "mirror://sourceforge/libusb/${name}.tar.bz2";
    sha256 = "0nn5icrfm9lkhzw1xjvaks9bq3w6mjg86ggv3fn7kgi4nfvg8kj0";
  };

  buildInputs = [
    libusb
  ];

  configureFlags = [
    "--enable-log"
    "--disable-debug-log"
    "--disable-examples-build"
  ];

  meta = with stdenv.lib; {
    description = "Userspace access to USB devices (libusb-0.1 compat wrapper)";
    homepage = http://www.libusb.info;
    license = licenses.lgpl21;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
