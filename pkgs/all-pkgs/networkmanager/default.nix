{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool

, avahi
, bind
, bluez
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
, modemmanager
, newt
, nss
, openresolv
, perl
, polkit
, ppp
, readline
, substituteAll
, systemd_lib
, util-linux_lib
, vala
, wirelesstools
, xz
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

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

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    bluez
    dbus_glib
    dnsmasq
    gobject-introspection
    libgcrypt
    libgudev
    libndp
    libnl
    libsoup
    modemmanager
    newt
    nss
    polkit
    ppp
    readline
    systemd_lib
    util-linux_lib
    vala
    wirelesstools
    xz
  ];

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "networkmanager/networkmanager-platform.patch";
      sha256 = "45d0235d3af0b8e471c2c7e14eb5bfc9e8029c6f5878c998e5273e84afab3e15";
    })
  ];

  preConfigure = ''
    substituteInPlace tools/glib-mkenums \
      --replace '/usr/bin/perl' '${perl}/bin/perl'
    substituteInPlace src/NetworkManagerUtils.c \
      --replace '/sbin/modprobe' '/run/current-system/sw/sbin/modprobe'
    substituteInPlace data/85-nm-unmanaged.rules \
      --replace '/bin/sh' '${stdenv.shell}' \
      --replace '/usr/sbin/ethtool' '${ethtool}/sbin/ethtool' \
      --replace '/bin/sed' '${gnused}/bin/sed'
    configureFlagsArray+=("--with-udev-dir=$out/lib/udev")
  '';

  configureFlags = [
    #"--with-distro=exherbo"
    "--sysconfdir=/etc"
    "--localstatedir=/var"

    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    #"--enable-config-plugin-ibft"
    "--disable-ifcfg-rh"
    "--disable-ifcfg-suse"
    "--disable-ifupdown"
    "--disable-ifnet"
    "--disable-code-coverage"
    "--enable-wifi"
    (enFlag "introspection" (gobject-introspection != null) null)
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
    (enFlag "vala" (vala != null) null)
    "--enable-tests"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"

    #"--with-config-plugins-default"
    #"--with-dist-version"
    "--with-wext"
    #"--with-udev-dir=$(out)/lib/udev"
    "--with-systemunitdir=$(out)/etc/systemd/system"
    "--with-session-tracking=systemd"
    "--with-suspend-resume=systemd"
    #"--with-selinux"
    "--with-crypto=nss"
    # TODO: make sure this path is correct
    "--with-dbus-sys-dir=\${out}/etc/dbus-1/system.d"
    #"--with-pppd-plugin-dir"
    "--with-pppd=${ppp}/bin/pppd"
    #"--with-pppoe"
    "--with-modem-manager-1"
    "--with-dhclient=${dhcp}/bin/dhclient"
    "--with-dhcpcd=${dhcpcd}/sbin/dhcpcd"
    "--with-resolvconf=${openresolv}/sbin/resolvconf"
    #"--with-netconfig"
    "--with-iptables=${iptables}/bin/iptables"
    "--with-dnsmasq=${dnsmasq}/bin/dnsmasq"
    #"--with-system-ca-path"
    "--with-kernel-firmware-dir=/run/current-system/firmware"
    "--with-libsoup"
    "--with-nmtui"
    "--without-valgrind"
    "--with-tests"
    "--without-valgrind-suppressions"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$out/var"
    )
  '';

  postInstall =
    /* FIXME: Workaround until Triton-LINUX dbus+systemd supports
       at_console policy */ ''
      substituteInPlace \
        $out/etc/dbus-1/system.d/org.freedesktop.NetworkManager.conf \
        --replace 'at_console="true"' 'group="networkmanager"'
    '' +
    /* systemd in Triton-LINUX doesn't use `systemctl enable`, so we
       need to establish aliases ourselves. */ ''
      mkdir -pv $out/etc/systemd/system
      ln -sv \
        $out/lib/systemd/system/NetworkManager.service \
        $out/etc/systemd/system/network-manager.service
      ln -sv \
        $out/lib/systemd/system/NetworkManager.service \
        $out/etc/systemd/system/dbus-org.freedesktop.NetworkManager.service
      ln -sv \
        $out/lib/systemd/system/NetworkManager-dispatcher.service \
        $out/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
    '' + ''
      sed -i $out/lib/udev/rules.d/84-nm-drivers.rules \
        -e 's|/bin/sh|${stdenv.shell}|'
    '';

  meta = with stdenv.lib; {
    description = "Network configuration and management tool";
    homepage = http://projects.gnome.org/NetworkManager/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
