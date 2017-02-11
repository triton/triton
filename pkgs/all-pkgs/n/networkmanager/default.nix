{ stdenv
, docbook-xsl
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, lib
, libxslt

, audit_lib
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
, jansson
, libgcrypt
, libgudev
, libndp
, libnl
, libselinux
, libsoup
#, libteam
, modemmanager
, newt
, nss
#, ofono
, openresolv
, perl
, polkit
, ppp
, python3Packages
, readline
, systemd_full
, util-linux_lib
, vala
, wpa_supplicant
, xz

, dhcp-client ? "dhclient"
  , dhcp
  , dhcpcd

, channel
}:

assert dhcp-client == "dhclient" || dhcp-client == "dhcpcd";
assert dhcp-client == "dhclient" -> dhcp != null;
assert dhcp-client == "dhcpcd" -> dhcpcd != null;

let
  inherit (lib)
    boolEn
    boolString
    boolWt
    optionals
    optionalString
    versionAtLeast;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "NetworkManager-${source.version}";

  src = fetchurl rec {
    url = "mirror://gnome/sources/NetworkManager/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    docbook-xsl
    gettext
    intltool
    libxslt
  ];

  buildInputs = [
    audit_lib
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
    jansson
    libgcrypt
    libgudev
    libndp
    libnl
    libselinux
    libsoup
    modemmanager
    newt
    nss
    openresolv
    perl
    polkit
    ppp
  ] ++ optionals (versionAtLeast channel "1.6") [
    python3Packages.python
    python3Packages.pygobject_3
  ] ++ [
    readline
    systemd_full
    util-linux_lib
    vala
    wpa_supplicant
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

  postPatch = ''
    patchShebangs ./tools/create-exports-NetworkManager.sh
  '' + /* FIXME: don't use an impure runtime path
                 fix hardcoded `mobprobe` search path */ ''
    sed -i src/NetworkManagerUtils.c \
      -e 's,/sbin/modprobe,/run/current-system/sw/sbin/modprobe,'
  '' + /* Fix hardcoded paths in source */ /*''
    sed -i src/devices/nm-device.c \
      -e 's,/usr/bin/ping,${inetutils}/bin/ping,'
  '' +*/ /* fix hardcoded paths in udev rules */ ''
    sed -i data/84-nm-drivers.rules \
      -e 's,/bin/sh,${stdenv.shell},'
    sed -i data/85-nm-unmanaged.rules \
      -e 's,/bin/sh,${stdenv.shell},' \
      -e 's,/usr/sbin/ethtool,${ethtool}/sbin/ethtool,' \
      -e 's,/bin/sed,${gnused}/bin/sed,'
  '' + /* Fix hardcoded paths in configure script */ ''
    sed -i configure{,.ac} \
      -e 's,/usr/bin/uname,${coreutils}/bin/uname,'
  '';

  preConfigure = ''
    configureFlagsArray+=(
      "--with-udev-dir=$out/lib/udev"
      "--with-systemunitdir=$out/etc/systemd/system"
      "--with-dbus-sys-dir=$out/etc/dbus-1/system.d"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"

    "PYTHON=python3"

    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    #"--enable-config-plugin-ibft"
    "--disable-ifcfg-rh"
    "--disable-ifcfg-suse"
    "--disable-ifupdown"
    "--disable-ifnet"
    "--disable-code-coverage"
    "--${boolEn (wpa_supplicant != null)}-wifi"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-qt"
    #"--enable-teamdctl"
  ] ++ optionals (versionAtLeast channel "1.6") [
    "--enable-json-validation"
  ] ++ [
    "--${boolEn (polkit != null)}-polkit"
    "--${boolEn (polkit != null)}-polkit-agent"
    #"--enable-modify-system"
    "--${boolEn (ppp != null)}-ppp"
    "--${boolEn (bluez != null)}-bluez5-dun"
    #"--enable-concheck"
    "--disable-more-warnings"
    "--disable-more-asserts"
    "--disable-more-logging"
    "--disable-lto"
    #"--enable-ld-gc"
    #"--enable-address-sanitizer"
    #"--enable-undefined-sanitizer"
    "--${boolEn (vala != null)}-vala"
    "--enable-tests"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"

    #"--with-config-plugins-default"
    "--${boolWt (wpa_supplicant != null)}-wext"
    "--with-libnm-glib"
    #"--with-hostname-persist=default"
    "--with-systemd-journal"
    #"--with-logging-backend"
    "--with-systemd-logind"
    "--without-consolekit"
    "--with-session-tracking=systemd"
    "--with-suspend-resume=systemd"
    "--${boolWt (libselinux != null)}-selinux"
    "--${boolWt (audit_lib != null)}-libaudit"
    "--with-crypto=nss"
    #"--with-dbus-sys-dir"
    # TODO: make sure this path is correct
    #"--with-pppd-plugin-dir"
    "--with-pppd=${ppp}/bin/pppd"
    "--with-modem-manager-1"
    "--with-ofono"
    "--${boolWt (dhcp-client == "dhclient")}-dhclient${
      boolString (dhcp-client == "dhclient") "=${dhcp}/bin/dhclient" ""}"
    "--${boolWt (dhcp-client == "dhcpcd")}-dhcpcd${
      boolString (dhcp-client == "dhcpcd") "=${dhcpcd}/bin/dhcpcd" ""}"
  ] ++ optionals (versionAtLeast channel "1.6") [
    "--${boolWt (dhcp-client == "dhcpcd")}-dhcpcd-supports-ipv6"
    "--with-config-dhcp-default=${dhcp-client}"
  ] ++ [
    "--with-resolvconf=${openresolv}/sbin/resolvconf"
    "--without-netconfig"
  ] ++ optionals (versionAtLeast channel "1.6") [
    #"--with-config-dns-rc-manager-default=symlink|file|netconfig|resolvconf"
  ] ++ [
    "--with-iptables=${iptables}/bin/iptables"
    "--with-dnsmasq=${dnsmasq}/bin/dnsmasq"
    #"--with-dnssec-trigger=/path/to/dnssec-trigger-script"
    #"--with-system-ca-path=/path/"
    # FIXME: fix impure path
    "--with-kernel-firmware-dir=/run/current-system/firmware"
    "--${boolWt (libsoup != null)}-libsoup"
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

  postInstall = /* FIXME: Workaround until Triton-LINUX dbus+systemd supports
                          at_console policy */ ''
    sed -i $out/etc/dbus-1/system.d/org.freedesktop.NetworkManager.conf \
      -e 's/at_console="true"/group="networkmanager"/'
  '' + /* systemd in Triton-LINUX doesn't use `systemctl enable`, so we
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

    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/NetworkManager/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
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
