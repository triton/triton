{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool

, avahi
, bind
, bluez
, coreutils
, dbus
, dbus-glib
, dnsmasq
, ethtool
, glib
, gnused
, gnutls
, gobject-introspection
#, inetutils
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
  , dhcp
  , dhcpcd
}:

let
  inherit (stdenv.lib)
    enFlag
    optionals
    wtFlag;
in

assert dhcp-client == "dhclient" || dhcp-client == "dhcpcd";
assert dhcp-client == "dhclient" -> dhcp != null;
assert dhcp-client == "dhcpcd" -> dhcpcd != null;

stdenv.mkDerivation rec {
  name = "NetworkManager-${version}";
  versionMajor = "1.4";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl rec {
    url = "mirror://gnome-insecure/sources/NetworkManager/${versionMajor}/"
      + "${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/NetworkManager/${versionMajor}/"
      + "${name}.sha256sum";
    sha256 = "c4d5e075998a291074501602a5068a7e54d9e0f2658aba079d58145d65be531d";
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
    #inetutils
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

  /*patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "networkmanager/networkmanager-platform.patch";
      sha256 = "45d0235d3af0b8e471c2c7e14eb5bfc9e8029c6f5878c998e5273e84afab3e15";
    })
  ];*/

  preConfigure =
    /* FIXME: don't use an impure runtime path
       fix hardcoded `mobprobe` search path */ ''
      sed -i src/NetworkManagerUtils.c \
        -e 's,/sbin/modprobe,/run/current-system/sw/sbin/modprobe,'
    '' + /* Fix hardcoded paths in source */ /*''
      sed -i src/devices/nm-device.c \
        -e 's,/usr/bin/ping,${inetutils}/bin/ping,'
    '' + *//* fix hardcoded paths in udev rules */ ''
      sed -i data/84-nm-drivers.rules \
        -e 's,/bin/sh,${stdenv.shell},'
      sed -i data/85-nm-unmanaged.rules \
        -e 's,/bin/sh,${stdenv.shell},' \
        -e 's,/usr/sbin/ethtool,${ethtool}/sbin/ethtool,' \
        -e 's,/bin/sed,${gnused}/bin/sed,'
    '' + /* Fix hardcoded paths in configure script */ ''
      sed -i configure{,.ac} \
        -e 's,/usr/bin/uname,${coreutils}/bin/uname,'
        #-e 's,/usr/bin/file,,'
    '' + ''
      configureFlagsArray+=(
        "--with-udev-dir=$out/lib/udev"
        "--with-systemunitdir=$out/etc/systemd/system"
        "--with-dbus-sys-dir=$out/etc/dbus-1/system.d"
      )
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
    #"--without-libnm-glib"
    #"--with-hostname-persist=default"
    "--with-systemd-journal"
    #"--with-logging-backend"
    "--with-systemd-logind"
    "--without-consolekit"
    "--with-session-tracking=systemd"
    "--with-suspend-resume=systemd"
    #"--with-selinux"
    #"--with-libaudit=yes-disabled-by-default"
    "--with-crypto=nss"
    #"--with-dbus-sys-dir"
    # TODO: make sure this path is correct
    #"--with-pppd-plugin-dir"
    "--with-pppd=${ppp}/bin/pppd"
    "--with-modem-manager-1"
    (wtFlag "dhclient" (dhcp-client == "dhclient") "${dhcp}/bin/dhclient")
    (wtFlag "dhcpcd" (dhcp-client == "dhcpcd") "${dhcpcd}/sbin/dhcpcd")
    "--with-resolvconf=${openresolv}/sbin/resolvconf"
    "--without-netconfig"
    "--with-iptables=${iptables}/bin/iptables"
    "--with-dnsmasq=${dnsmasq}/bin/dnsmasq"
    #"--with-dnssec-trigger=/path/to/dnssec-trigger-script"
    #"--with-system-ca-path=/path/"
    # FIXME: fix impure path
    "--with-kernel-firmware-dir=/run/current-system/firmware"
    (wtFlag "libsoup" (libsoup != null) null)
    "--with-nmcli"
    "--with-nmtui"
    "--with-more-asserts=0"
    "--without-valgrind"
    "--with-tests"
    "--without-valgrind-suppressions"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$out/var"
      "runstatedir=$out/var/run"
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
    description = "https://wiki.gnome.org/Projects/NetworkManager";
    homepage = http://projects.gnome.org/NetworkManager/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
