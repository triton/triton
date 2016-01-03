{ stdenv
, fetchurl
, intltool
, pkgconfig
, python

, atk
, at-spi2-core
, dbus_glib
, glib
, popt
, xorg

, libxml2
}:

with {
  inherit (stdenv.lib)
    optionals
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "at-spi2-atk-${version}";
  versionMajor = "2.18";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/at-spi2-atk/${versionMajor}/${name}.tar.xz";
    sha256 = "0bf1g5cj84rmx7p1q547vwbc0hlpcs2wrxnmv96lckfkhs9mzcf4";
  };

  configureFlags = [
    "--enable-schemas-compile"
    "--enable-p2p"
    (wtFlag "tests" doCheck null)
  ];

  nativeBuildInputs = [
    intltool
    python
  ];

  buildInputs = [
    atk
    dbus_glib
    glib
    popt
    at-spi2-core
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXi
    xorg.libXtst
  ] ++ optionals doCheck [
    libxml2
  ];

  doCheck = false;
  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Gtk module for bridging AT-SPI to Atk";
    homepage = https://wiki.gnome.org/Accessibility;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
