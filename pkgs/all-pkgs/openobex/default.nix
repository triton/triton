{ stdenv
, cmake
, fetchurl
, ninja

, bluez
, libusb
, udev
}:

stdenv.mkDerivation rec {
  name = "openobex-1.7.1";

  src = fetchurl {
    url = "mirror://sourceforge/openobex/${name}-Source.tar.gz";
    sha256 = "0mza0mrdrbcw4yix6qvl31kqy7bdkgxjycr0yx7yl089v5jlc9iv";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    bluez
    libusb
    udev
  ];

  postPatch = ''
    sed -i udev/CMakeLists.txt \
      -e "s!/lib/udev!$out/lib/udev!" \
      -e "/if ( PKGCONFIG_UDEV_FOUND )/,/endif ( PKGCONFIG_UDEV_FOUND )/d"
  '';

  meta = with stdenv.lib; {
    description = "OBEX protocol used for transferring data to mobile devices";
    homepage = http://sourceforge.net/projects/openobex/;
    license = with licenses; [
      gpl2
      lgpl21
    ];
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
