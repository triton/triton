{ stdenv
, fetchTritonPatch
, fetchzip
, which

, boost
, dbus
, libtorrent-rasterbar
, qt5
, zlib

, webuiSupport ? true
}:

let
  inherit (stdenv.lib)
    enFlag
    optionals;

  version = "3.3.5";
in

assert qt5 != null -> dbus != null;

stdenv.mkDerivation rec {
  name = "qbittorrent-" + version;

  src = fetchzip {
    url = "https://github.com/qbittorrent/qBittorrent/archive/"
      + "release-${version}.tar.gz";
    sha256 = "4dc222e0362765f57b2f9177e8f2f1fd2ecae6c0626b7a5ba6e4b4e0d3886de8";
  };

  nativeBuildInputs = [
    which
  ];

  buildInputs = [
    boost
    libtorrent-rasterbar
    zlib
  ] ++ optionals (qt5 != null) [
    dbus
    qt5
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
    (enFlag "qt-dbus" (qt5 != null && dbus != null) null)
    "--without-qt4"
    "--with-qtsingleapplication=shipped"
    "--with-qjson=system"
    "--with-boost=${boost.dev}"
    "--with-boost-libdir=${boost.lib}/lib"
    "--with-boost-system"
  ];

  meta = with stdenv.lib; {
    description = "BitTorrent client in C++ and Qt";
    homepage = http://www.qbittorrent.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
