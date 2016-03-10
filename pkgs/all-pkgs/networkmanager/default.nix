{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool

, avahi
, bind
, bluez
, dbus
, dbus-glib
, dnsmasq
, ethtool
, glib
, gnused
, gnutls
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
, systemd_full
, util-linux_lib
, vala
, wirelesstools
, xz

, dhcp-client ? "dhclient"
  , dhcp ? null
  , dhcpcd ? null
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals
    wtFlag;
};

assert dhcp-client == "dhclient" || dhcp-client == "dhcpcd";
assert dhcp-client == "dhclient" -> dhcp != null;
assert dhcp-client == "dhcpcd" -> dhcpcd != null;

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
    avahi
    bind
    bluez
    dbus
    dbus-glib
    dnsmasq
    ethtool
    glib
    gnused
    gnutls
    gobject-introspection
    iptables
    libgcrypt
    libgudev
    libndp
    libnl
    libsoup
    modemmanager
    newt
    nss
    openresolv
    perl
    polkit
    ppp
    readline
    systemd_full
    util-linux_lib
    vala
    wirelesstools
    xz
  ] ++ optionals (dhcp-client == "dhclient") [
    dhcp
  ] ++ optionals (dhcp-client == "dhcpcd") [
    dhcpcd
  ];

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "networkmanager/networkmanager-platform.patch";
      sha256 = "45d0235d3af0b8e471c2c7e14eb5bfc9e8029c6f5878c998e5273e84afab3e15";
    })
  ];

  preConfigure =
    /* fix hardcoded `mobprobe` search path */ ''
      sed -i src/NetworkManagerUtils.c \
        -e 's,/sbin/modprobe,/run/current-system/sw/sbin/modprobe,'
    '' + /* fix hardcoded paths in udev rules */ ''
      sed -i data/84-nm-drivers.rules \
        -e 's,/bin/sh,${stdenv.shell},'
      sed -i data/85-nm-unmanaged.rules \
        -e 's,/bin/sh,${stdenv.shell},' \
        -e 's,/usr/sbin/ethtool,${ethtool}/sbin/ethtool,' \
        -e 's,/bin/sed,${gnused}/bin/sed,'
    '' + ''
      configureFlagsArray+=("--with-udev-dir=$out/lib/udev")
    '';

  configureFlags = [
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
    (enFlag "polkit" (polkit != null) null)
    (enFlag "polkit-agent" (polkit != null) null)
    #"--enable-modify-system"
    (enFlag "ppp" (ppp != null) null)
    "--enable-bluez5-dun"
    #"--enable-concheck"
    "--disable-more-warnings"
    "--disable-more-asserts"
    "--disable-more-logging"
    "--disable-lto"
    (enFlag "vala" (vala != null) null)
    "--enable-tests"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"

    #"--with-config-plugins-default"
    "--with-wext"
    "--with-udev-dir=$(out)/lib/udev"
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
    (wtFlag "dhclient" (dhcp-client == "dhclient") "${dhcp}/bin/dhclient")
    (wtFlag "dhcpcd" (dhcp-client == "dhcpcd") "${dhcpcd}/sbin/dhcpcd")
    "--with-resolvconf=${openresolv}/sbin/resolvconf"
    #"--with-netconfig"
    "--with-iptables=${iptables}/bin/iptables"
    "--with-dnsmasq=${dnsmasq}/bin/dnsmasq"
    #"--with-system-ca-path"
    "--with-kernel-firmware-dir=/run/current-system/firmware"
    (wtFlag "libsoup" (libsoup != null) null)
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
      sed -i $out/etc/dbus-1/system.d/org.freedesktop.NetworkManager.conf \
        -e 's/at_console="true"/group="networkmanager"/'
    '' +
    /* systemd in Triton-LINUX doesn't use `systemctl enable`, so we
       need to establish aliases ourselves. */ ''
      mkdir -pv $out/etc/systemd/system
      ln -sv \
        $out/lib/systemd/system/NetworkManager.service \
        $out/etc/systemd/system/networkmanager.service
      ln -sv \
        $out/lib/systemd/system/NetworkManager.service \
        $out/etc/systemd/system/dbus-org.freedesktop.NetworkManager.service
      ln -sv \
        $out/lib/systemd/system/NetworkManager-dispatcher.service \
        $out/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
    '';

  passthru = {
    inherit
      dhcp-client;
  };

  meta = with stdenv.lib; {
    description = "Network configuration and management tool";
    homepage = http://projects.gnome.org/NetworkManager/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
