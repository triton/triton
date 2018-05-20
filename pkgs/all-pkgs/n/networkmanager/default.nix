{ stdenv
, docbook-xsl
, fetchpatch
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
, curl
, dbus
, dbus-glib
, dnsmasq
, ethtool
, glib
, gnused
, gnutls
, gobject-introspection
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
, openconnect
, openresolv
, perl
, polkit
, ppp
, python3Packages
, readline
, systemd_lib
, tzdata
, util-linux_lib
, vala
, wpa_supplicant
, xz

, dhcp-client ? "dhclient"
  , dhcp
  , dhcpcd

, findHardcodedPaths ? false  # for derivation testing only

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

  sources = {
    "1.10" = {
      version = "1.10.8";
      sha256 = "eb4ac8ce75fed5ec804f409caec7b54342d4e01512baf7d7fc119fd40ac8a938";
    };
  };
  source = sources."${channel}";
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
    vala
  ];

  buildInputs = [
    audit_lib
    avahi
    bind
    bluez
    curl
    dbus
    dbus-glib
    dhcp
    dhcpcd
    dnsmasq
    ethtool
    glib
    gnused
    gnutls
    gobject-introspection
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
    python3Packages.python
    python3Packages.pygobject
    readline
    systemd_lib
    util-linux_lib
    wpa_supplicant
    xz
  ];

  /*patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "networkmanager/networkmanager-platform.patch";
      sha256 = "45d0235d3af0b8e471c2c7e14eb5bfc9e8029c6f5878c998e5273e84afab3e15";
    })
  ];*/

  # FIXME: fix hard coded resolvconf paths
  postPatch = ''
    patchShebangs ./tools/create-exports-NetworkManager.sh
  '' + /* Fix hardcoded paths in source */ ''
    sed -i clients/cli/utils.c \
      -e 's,/bin/sh,${stdenv.shell},g'
    # FIXME IMPURE
    sed -i src/devices/nm-device.c \
      -e 's,/usr/bin/ping,/var/setuid-wrappers/ping,g'
    # FIXME IMPURE
    sed -i src/NetworkManagerUtils.c \
      -i src/nm-core-utils.c \
      -e 's,/sbin/modprobe,/run/current-system/sw/bin/modprobe,g'
    # ???: do we need netconfig
    sed -i src/dns/nm-dns-manager.c \
      -e 's,/sbin/resolvconf,${openresolv}/bin/resolvconf,' \
      -e 's,/sbin/netconfig,/non-existent-path/netconfig,'
    sed -i clients/common/nm-vpn-helpers.c \
      -e 's,/usr/sbin/openconnect,${openconnect}/bin/openconnect,'
    sed -i src/systemd/src/basic/time-util.c \
      -i src/systemd/src/basic/time-util.c \
      -e 's,/usr/share/zoneinfo,${tzdata}/share/zoneinfo,g'
    sed -i src/systemd/src/basic/path-util.c \
      -e 's,"/.*/true,"${coreutils}/bin/true,g'
    # Prevent loading from impure paths
    sed -i src/nm-core-utils.c \
      -i clients/common/nm-vpn-helpers.c \
      -e 's,^\s\+"/\(usr\|bin\|sbin\),"/non-existent-path,g'
    # Prevent loading from impure paths
    sed -i src/systemd/src/basic/path-util.h \
      -e 's,/\(usr\|bin\|sbin\),/non-existent-path,g'
    # FIXME IMPURE
    sed -i data/NetworkManager.service.in \
      -e 's,/usr/bin/dbus-send,/run/current-system/sw/bin/dbus-send,' \
      -e 's,/bin/kill,${coreutils}/bin/kill,'
    sed -i data/org.freedesktop.NetworkManager.service.in \
      -e 's,/bin/false,${coreutils}/bin/false,'
    sed -i data/84-nm-drivers.rules \
      -e 's,/bin/sh,${stdenv.shell},' \
      -e 's,ethtool,${ethtool}/bin/ethtool,' \
      -e 's,sed -n,${gnused}/bin/sed -n,'
  '' + /* Fix hardcoded paths in configure script */ ''
    sed -i configure{,.ac} \
      -e 's,/usr/bin/uname,${coreutils}/bin/uname,'
  '' + optionalString findHardcodedPaths ''
    rm -rf build-aux configure{,.ac} m4/ man/ docs INSTALL *.m4
    grep -rP '^(?!#!).*/(usr|bin|sbin).*'; return 1
  '';

  preConfigure = ''
    configureFlagsArray+=(
      "--with-udev-dir=$out/lib/udev"
      "--with-systemdsystemunitdir=$out/lib/systemd/system"
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
    "--enable-json-validation"
    "--${boolEn (polkit != null)}-polkit"
    "--${boolEn (polkit != null)}-polkit-agent"
    #"--enable-modify-system"
    "--${boolEn (ppp != null)}-ppp"
    "--${boolEn (bluez != null)}-bluez5-dun"
    "--${boolEn (curl != null)}-concheck"
    "--disable-more-warnings"
    "--disable-more-asserts"
    "--disable-more-logging"
    "--disable-lto"
    #"--enable-ld-gc"
    #"--enable-address-sanitizer"
    #"--enable-undefined-sanitizer"
    "--${boolEn (vala != null)}-vala"
    "--disable-tests"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"

    #"--with-config-plugins-default"
    "--${boolWt (wpa_supplicant != null)}-wext"
    "--with-libnm-glib"
    #"--with-hostname-persist=default"
    "--with-systemd-journal"
    "--with-config-logging-backend-default=journal"
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
    "--with-dhcpcanon"
    "--${boolWt (dhcp != null)}-dhclient${
        if dhcp != null then "=${dhcp}/bin/dhclient" else ""}"
    "--${boolWt (dhcpcd != null)}-dhcpcd${
        if dhcpcd != null then "=${dhcpcd}/bin/dhcpcd" else ""}"
    "--${boolWt (dhcp-client == "dhcpcd")}-dhcpcd-supports-ipv6"
    "--with-config-dhcp-default=${dhcp-client}"
    "--with-resolvconf=${openresolv}/bin/resolvconf"
    "--without-netconfig"
    #"--with-config-dns-rc-manager-default=symlink|file|netconfig|resolvconf"
    "--with-iptables=${iptables}/bin/iptables"
    "--with-dnsmasq=${dnsmasq}/bin/dnsmasq"
    #"--with-dnssec-trigger=/path/to/dnssec-trigger-script"
    #"--with-system-ca-path=/path/"
    # FIXME IMPURE
    "--with-kernel-firmware-dir=/run/current-system/firmware"
    #"--with-libpsl"
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
