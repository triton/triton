{ stdenv
, fetchurl
, gettext

, dbus
, expat
, glib
}:

stdenv.mkDerivation rec {
  name = "dbus-glib-0.106";

  src = fetchurl {
    url = "https://dbus.freedesktop.org/releases/dbus-glib//${name}.tar.gz";
    sha256 = "0in0i6v68ixcy0ip28i84hdczf10ykq9x682qgcvls6gdmq552dk";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    dbus
    expat
    glib
  ];

  meta = with stdenv.lib; {
    description = "Obsolete glib bindings for D-Bus lightweight IPC mechanism";
    homepage = http://dbus.freedesktop.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
