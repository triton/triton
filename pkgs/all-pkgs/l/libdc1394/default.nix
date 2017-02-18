{ stdenv
, fetchurl
, lib

, libraw1394
, libusb_1
}:

let
  version = "2.2.5";
in
stdenv.mkDerivation rec {
  name = "libdc1394-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libdc1394/libdc1394-2/${version}/"
      + "${name}.tar.gz";
    sha256 = "350cc8d08aee5ffc4e1f3049e2e1c2bc6660642d424595157da97ab5b1263337";
  };

  buildInputs = [
    libraw1394
    libusb_1
  ];

  meta = with lib; {
    description = "Capture and control API for IIDC compliant cameras";
    homepage = http://sourceforge.net/projects/libdc1394/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
