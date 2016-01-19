{ stdenv, fetchTritonPatch, fetchurl, intltool, pkgconfig, dbus_glib
, udev, libnl, libuuid, gnutls, dhcp
, libgcrypt, perl, libgudev }:

stdenv.mkDerivation rec {
  name = "network-manager-${version}";
  version = "0.9.8.10";

  src = fetchurl {
    url = "mirror://gnome/sources/NetworkManager/0.9/NetworkManager-${version}.tar.xz";
    sha256 = "0wn9qh8r56r8l19dqr68pdl1rv3zg1dv47rfy6fqa91q7li2fk86";
  };

  preConfigure = ''
    substituteInPlace tools/glib-mkenums --replace /usr/bin/perl ${perl}/bin/perl
  '';

  # Right now we hardcode quite a few paths at build time. Probably we should
  # patch networkmanager to allow passing these path in config file. This will
  # remove unneeded build-time dependencies.
  configureFlags = [
    "--with-distro=exherbo"
    "--with-dhclient=${dhcp}/sbin/dhclient"
    "--with-dhcpcd=no"
    "--with-iptables=no"
    "--with-udev-dir=\${out}/lib/udev"
    "--with-resolvconf=no"
    "--sysconfdir=/etc" "--localstatedir=/var"
    "--with-dbus-sys-dir=\${out}/etc/dbus-1/system.d"
    "--with-crypto=gnutls" "--disable-more-warnings"
    "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
    "--with-kernel-firmware-dir=/run/current-system/firmware"
    "--disable-ppp"
  ];

  buildInputs = [ udev libnl libuuid gnutls libgcrypt libgudev ];

  propagatedBuildInputs = [ dbus_glib ];

  nativeBuildInputs = [ intltool pkgconfig ];

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "networkmanager/libnl-3.2.25.patch";
      sha256 = "239e2d55430ce75c02d3deb6bac2866bb802916687d7494d3d8b9cf68bff0d62";
    })
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "networkmanager/networkmanager-nixos-purity.patch";
      sha256 = "1dcb30fe8f52df17df7f46230acd27a881b4e4e01ff074c36bf9d2efc9e39fca";
    })
  ];

  preInstall =
    ''
      installFlagsArray=( "sysconfdir=$out/etc" "localstatedir=$out/var" )
    '';

  meta = with stdenv.lib; {
    homepage = http://projects.gnome.org/NetworkManager/;
    description = "Network configuration and management tool";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
