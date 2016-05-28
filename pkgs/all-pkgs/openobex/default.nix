{ stdenv
, cmake
, fetchurl
, ninja

, bluez
, libusb
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "openobex-1.7.2";

  src = fetchurl {
    url = "mirror://sourceforge/openobex/${name}-Source.tar.gz";
    sha256 = "158860aaea52f0fce0c8e4b64550daaae06df2689e05834697b7e8c7d73dd4fc";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    bluez
    libusb
    systemd_lib
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
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
