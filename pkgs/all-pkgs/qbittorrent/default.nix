{ stdenv
, fetchTritonPatch
, fetchurl
, which

, boost
, dbus_libs
, libtorrent-rasterbar
, qt5
, webuiSupport ? true
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals;
};

assert qt5 != null ->
  dbus_libs != null &&
  qt5.qtbase != null &&
  qt5.qttools != null;

stdenv.mkDerivation rec {
  name = "qbittorrent-${version}";
  version = "3.3.3";

  src = fetchurl {
    url = "mirror://sourceforge/qbittorrent/${name}.tar.xz";
    sha256 = "0lyv230vqwb77isjqm6fwwgv8hdap88zir9yrccj0qxj7zf8p3cw";
  };

  nativeBuildInputs = [
    which
  ];

  buildInputs = [
    boost
    libtorrent-rasterbar
  ] ++ optionals (qt5 != null) [
    dbus_libs
    qt5.qtbase
    qt5.qttools
  ];

  patches = [
    # The lrelease binary is named lrelease instead of lrelease-qt5
    (fetchTritonPatch {
      rev = "2b33aa1bf7a7c334e1099e7de4f05a11065c698c";
      file = "qbittorrent/qbittorrent-fix-lrelease.patch";
      sha256 = "cfe72a7016e1ea1d23032654350c230f149189457deeb6d8b491eff6dac1e7ff";
    })
  ];

  configureFlags = [
    "--disable-debug"
    (enFlag "gui" (qt5 != null) null)
    "--enable-systemd"
    (enFlag "webui" webuiSupport null)
    (enFlag "qt-dbus" (qt5 != null && dbus_libs != null) null)
    "--without-qt4"
    "--with-qtsingleapplication=shipped"
    "--with-qjson=system"
    "--with-boost=${boost.dev}"
    "--with-boost-libdir=${boost.lib}/lib"
    "--with-boost-system"
  ];

  meta = {
    description = "BitTorrent client in C++ and Qt";
    homepage = http://www.qbittorrent.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
