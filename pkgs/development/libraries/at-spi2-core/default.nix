{ stdenv, fetchurl, python, popt, intltool, dbus_glib, xorg, gobjectIntrospection }:

stdenv.mkDerivation rec {
  versionMajor = "2.18";
  versionMinor = "0";
  moduleName   = "at-spi2-core";
  name = "${moduleName}-${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/${moduleName}/${versionMajor}/${name}.tar.xz";
    sha256 = "0xna0gnlqvzy6209klirywcm7ianazshg6pkk828g07bnrywgvhs";
  };

  outputs = [ "out" "doc" ];

  buildInputs = [
    python popt intltool dbus_glib
    xorg.libX11 xorg.xextproto xorg.libSM xorg.libICE xorg.libXtst xorg.libXi
    gobjectIntrospection
  ];

  # ToDo: on non-NixOS we create a symlink from there?
  configureFlags = "--with-dbus-daemondir=/run/current-system/sw/bin/";

  NIX_LDFLAGS = with stdenv; lib.optionalString isDarwin "-lintl";

  meta = with stdenv.lib; {
    platforms = platforms.unix;
  };
}

