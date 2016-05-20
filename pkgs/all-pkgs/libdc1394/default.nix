{ stdenv
, fetchurl

, libraw1394
, libusb_1
}:

stdenv.mkDerivation rec {
  name = "libdc1394-2.2.4";

  src = fetchurl {
    url = "mirror://sourceforge/libdc1394/${name}.tar.gz";
    sha256 = "a93689a353c241884a98727128f315ecf9965db70dca710b08af10e5fa0d2e6f";
  };

  buildInputs = [
    libraw1394
    libusb_1
  ];

  meta = with stdenv.lib; {
    homepage = http://sourceforge.net/projects/libdc1394/;
    description = "Capture and control API for IIDC compliant cameras";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
