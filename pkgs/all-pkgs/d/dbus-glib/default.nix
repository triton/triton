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
    url = "https://dbus.freedesktop.org/releases/dbus-glib/${name}.tar.gz";
    multihash = "QmZEuNUHEMkwgSEGAkQ4gzi11bniqLut3bjTnismHwyTvY";
    sha256 = "b38952706dcf68bad9c302999ef0f420b8cf1a2428227123f0ac4764b689c046";
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
