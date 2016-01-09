{ stdenv
, fetchurl
, gettext
, intltool

, avahi
, bind
, bluez5
, dbus_glib
, dhcp
, dhcpcd
, dnsmasq
, ethtool
, gnused
, gobject-introspection
, iptables
, libgcrypt
, libgudev
, libndp
, libnl
, libsoup
, libuuid
, modemmanager
, newt
, nss
, openresolv
, perl
, polkit
, ppp
, readline
, substituteAll
, udev
, vala
, wirelesstools
, xz
}:

stdenv.mkDerivation rec {
  name = "network-manager-${version}";
  versionMajor = "1.0";
  versionMinor = "10";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/NetworkManager/${versionMajor}/" +
          "NetworkManager-${version}.tar.xz";
    sha256 = "1g4z2wg036n0njqp8fycrisj46l3yda6pl00l4rg9nfz862cxkqv";
  };

  patches = [
    ./nm-platform.patch
  ];

  configureFlags = [
    "--with-distro=exherbo"
    "--sysconfdir=/etc"
    "--localstatedir=/var"

    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    #"--enable-config-plugin-ibft"
    #"--enable-ifcfg-rh"
    #"--enable-ifcfg-suse"
    #"--enable-ifupdown"
    #"--enable-ifnet"
    "--disable-code-coverage"
    "--enable-wifi"
    "--enable-introspection"
    "--disable-qt"
    # TODO: wimax support, requires intel wimax sdk
    "--disable-wimax"
    #"--enable-teamdctl"
    "--enable-polkit"
    "--enable-polkit-agent"
    #"--enable-modify-system"
    "--enable-ppp"
    "--enable-bluez5-dun"
    #"--enable-concheck"
    "--enable-more-warnings"
    "--disable-more-asserts"
    "--disable-more-logging"
    "--disable-lto"
    # TODO: vala support
    "--disable-vala"
    "--enable-tests"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"

    #"--with-config-plugins-default"
    #"--with-dist-version"
    "--with-wext"
    #"--with-udev-dir"
    #"--with-udev-dir=$(out)/lib/udev"
    "--with-systemunitdir=$(out)/etc/systemd/system"
    "--with-session-tracking=systemd"
    "--with-suspend-resume=systemd"
    #"--with-selinux"
    "--with-crypto=nss"
    "--with-dbus-sys-dir=\${out}/etc/dbus-1/system.d"
    #"--with-pppd-plugin-dir"
    "--with-pppd=${ppp}/bin/pppd"
    #"--with-pppoe"
    "--with-modem-manager-1"
    "--with-dhclient=${dhcp}/bin/dhclient"
    # Upstream prefers dhclient, so don't add dhcpcd to the closure
    "--without-dhcpcd" # ???
    #"--with-dhcpcd=${dhcpcd}/sbin/dhcpcd"
    "--with-resolvconf=${openresolv}/sbin/resolvconf"
    #"--with-netconfig"
    "--with-iptables=${iptables}/bin/iptables"
    "--with-dnsmasq=${dnsmasq}/bin/dnsmasq"
    #"--with-system-ca-path"
    "--with-kernel-firmware-dir=/run/current-system/firmware" #
    "--with-libsoup" #
    "--with-nmtui" #
    "--without-valgrind" #
    "--with-tests" #
    "--without-valgrind-suppressions" #
  ];

  preConfigure = ''
    substituteInPlace tools/glib-mkenums \
      --replace /usr/bin/perl ${perl}/bin/perl
    substituteInPlace src/NetworkManagerUtils.c \
      --replace /sbin/modprobe /run/current-system/sw/sbin/modprobe
    substituteInPlace data/85-nm-unmanaged.rules \
      --replace /bin/sh ${stdenv.shell} \
      --replace /usr/sbin/ethtool ${ethtool}/sbin/ethtool \
      --replace /bin/sed ${gnused}/bin/sed
    configureFlagsArray+=("--with-udev-dir=$out/lib/udev")
  '';

  /*configurePhase = ''
    ./configure --help
  '';*/

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    bluez5
    dbus_glib
    dnsmasq
    gobject-introspection
    libgcrypt
    libgudev
    libndp
    libnl
    libsoup
    libuuid
    modemmanager
    newt
    nss
    polkit
    ppp
    readline
    udev
    #vala
    wirelesstools
    xz
  ];

  preInstall = ''
    installFlagsArray=(
      "sysconfdir=$out/etc"
      "localstatedir=$out/var"
    )
  '';

  postInstall = ''

    # FIXME: Workaround until NixOS' dbus+systemd supports at_console policy
    substituteInPlace $out/etc/dbus-1/system.d/org.freedesktop.NetworkManager.conf \
      --replace 'at_console="true"' 'group="networkmanager"'

    # rename to network-manager to be in style
    #mv -v $out/etc/systemd/system/NetworkManager.service \
    #  $out/etc/systemd/system/network-manager.service

    # systemd in NixOS doesn't use `systemctl enable`, so we need to establish
    # aliases ourselves.
    mkdir -pv $out/etc/systemd/system
    ln -sv $out/lib/systemd/system/NetworkManager.service \
      $out/etc/systemd/system/network-manager.service
    ln -sv $out/lib/systemd/system/NetworkManager.service \
      $out/etc/systemd/system/dbus-org.freedesktop.NetworkManager.service
    ln -sv $out/lib/systemd/system/NetworkManager-dispatcher.service \
      $out/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Network configuration and management tool";
    homepage = http://projects.gnome.org/NetworkManager/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
