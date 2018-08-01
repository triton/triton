{ stdenv
, fetchurl
, gobject-introspection
, meson
, ninja
, vala

, hwdata
, glib
, libusb
}:

stdenv.mkDerivation rec {
  name = "libgusb-0.3.0";

  src = fetchurl {
    url = "https://people.freedesktop.org/~hughsient/releases/${name}.tar.xz";
    multihash = "QmVgV6uEaDVWJm17DXm2fRTHDkpMjfCrL2RYPkZ6evdQH6";
    sha256 = "d8e7950f99b6ae4c3e9b8c65f3692b9635289e6cff8de40c4af41b2e9b348edc";
  };

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    vala
  ];

  buildInputs = [
    glib
    libusb
  ];

  mesonFlags = [
    "-Dtests=false"
    "-Dusb_ids=${hwdata}/share/hwdata/usb.ids"
    "-Ddocs=false"
  ];

  setVapidirInstallFlag = false;

  meta = with stdenv.lib; {
    description = "GObject wrapper for libusb";
    homepage = https://github.com/hughsie/libgusb;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codeyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
