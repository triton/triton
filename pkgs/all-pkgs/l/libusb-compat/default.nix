{ stdenv
, fetchurl

, libusb
}:

let
  major = "0.1";
  patch = "5";
  version = "${major}.${patch}";
in
stdenv.mkDerivation rec {
  name = "libusb-compat-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libusb/libusb-compat-${major}/${name}/${name}.tar.bz2";
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
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
