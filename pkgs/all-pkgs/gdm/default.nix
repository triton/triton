{ stdenv, fetchurl, pkgconfig, glib, itstool, libxml2, xorg, dbus
, intltool, accountsservice, systemd, gnome-session, gtk3
, libcanberra, pam, libtool, gobjectIntrospection, dconf }:

stdenv.mkDerivation rec {
  name = "gdm-3.14.2";

  src = fetchurl {
    url = mirror://gnome/sources/gdm/3.14/gdm-3.14.2.tar.xz;
    sha256 = "e20eb61496161ad95b1058dbf8aea9b7b004df4d0ea6b0fab4401397d9db5930";
  };

  # Only needed to make it build
  preConfigure = ''
    substituteInPlace ./configure --replace "/usr/bin/X" "${xorg.xorgserver}/bin/X"
  '';

  configureFlags = [ "--sysconfdir=/etc"
                     "--localstatedir=/var"
                     "--with-systemd=yes"
                     "--with-systemdsystemunitdir=$(out)/etc/systemd/system" ];

  buildInputs = [ pkgconfig glib itstool libxml2 intltool
                  accountsservice dconf systemd
                  gobjectIntrospection xorg.libX11 gtk3
                  xorg.libXrandr
                  libcanberra pam libtool xorg.libXi xorg.libXext ];

  #enableParallelBuilding = true; # problems compiling

  preBuild = ''
    substituteInPlace daemon/gdm-simple-slave.c --replace 'BINDIR "/gnome-session' '"${gnome-session}/bin/gnome-session'
  '';

  # Disable Access Control because our X does not support FamilyServerInterpreted yet
  patches = [ ./xserver_path.patch ./sessions_dir.patch
              ./disable_x_access_control.patch ./no-dbus-launch.patch ];

  installFlags = [ "sysconfdir=$(out)/etc" "dbusconfdir=$(out)/etc/dbus-1/system.d" ];

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Projects/GDM;
    description = "A program that manages graphical display servers and handles graphical user logins";
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
    #maintainers = gnome3.maintainers;
  };
}
