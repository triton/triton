{ stdenv, fetchurl, pkgconfig, libtool, python, perl, texinfo, flex, bison
, gettext, makeWrapper, glib, zlib, pixman

# Optional Arguments
, SDL2 ? null, gtk ? null, vte ? null, nettle ? null, gnutls ? null
, cyrus_sasl ? null, libjpeg ? null, libpng ? null, ncurses ? null, curl ? null
, libcap ? null, attr ? null, bluez ? null, libibverbs ? null, librdmacm ? null
, libuuid ? null, vde2 ? null, libaio ? null, libcap_ng ? null, spice ? null
, spice_protocol ? null, libceph ? null, libxfs ? null, nss ? null, nspr ? null
, libusb ? null, usbredir ? null, mesa ? null, epoxy ? null, lzo ? null
, snappy ? null, bzip2 ? null, libseccomp ? null, glusterfs ? null
, libssh2 ? null, numactl ? null, gperftools ? null

# Audio libraries
, libpulseaudio ? null, alsaLib ? null

# Extra options
, type ? ""
}:

with stdenv;
with stdenv.lib;
let
  n = "qemu-2.4.0";

  isKvmOnly = type == "kvm-only";
  isNix = type == "nix";

  optSDL2 = if isNix then null else shouldUsePkg SDL2;
  optGtk = if isNix then null else shouldUsePkg gtk;
  optVte = if isNix then null else shouldUsePkg vte;
  optLibcap = if isNix then null else shouldUsePkg libcap;
  optAttr = if isNix then null else shouldUsePkg attr;
  optNettle = if isNix then null else shouldUsePkg nettle;
  optGnutls = if isNix || optNettle == null then null else shouldUsePkg gnutls;
  optCyrus_sasl = if isNix then null else shouldUsePkg cyrus_sasl;
  optLibjpeg = if isNix then null else shouldUsePkg libjpeg;
  optLibpng = if isNix then null else shouldUsePkg libpng;
  optNcurses = if isNix then null else shouldUsePkg ncurses;
  optCurl = if isNix then null else shouldUsePkg curl;
  optBluez = if isNix then null else shouldUsePkg bluez;
  optLibibverbs = if isNix then null else shouldUsePkg libibverbs;
  optLibrdmacm = if isNix then null else shouldUsePkg librdmacm;
  optLibuuid = if isNix then null else shouldUsePkg libuuid;
  optVde2 = if isNix then null else shouldUsePkg vde2;
  optLibaio = shouldUsePkg libaio;
  optLibcap_ng = if isNix then null else shouldUsePkg libcap_ng;
  optSpice = if isNix then null else shouldUsePkg spice;
  optSpice_protocol = if isNix then null else shouldUsePkg spice_protocol;
  optLibceph = if isNix then null else shouldUsePkg libceph;
  optLibxfs = if isNix then null else shouldUsePkg libxfs;
  optNss = if isNix then null else shouldUsePkg nss;
  optNspr = if isNix then null else shouldUsePkg nspr;
  optLibusb = if isNix then null else shouldUsePkg libusb;
  optUsbredir = if isNix then null else shouldUsePkg usbredir;
  optMesa = if isNix then null else shouldUsePkg mesa;
  optEpoxy = if isNix then null else shouldUsePkg epoxy;
  optLzo = if isNix then null else shouldUsePkg lzo;
  optSnappy = if isNix then null else shouldUsePkg snappy;
  optBzip2 = if isNix then null else shouldUsePkg bzip2;
  optLibseccomp = if isNix then null else shouldUsePkg libseccomp;
  optGlusterfs = if isNix then null else shouldUsePkg glusterfs;
  optLibssh2 = if isNix then null else shouldUsePkg libssh2;
  optNumactl = if isNix then null else shouldUsePkg numactl;
  optGperftools = if isNix then null else shouldUsePkg gperftools;

  hasSDLAbi = if optSDL2 != null then true else null;

  hasVirtfs = stdenv.isLinux && optLibcap != null && optAttr != null;

  hasVnc = !isNix;
  hasVncTls = hasVnc && optGnutls != null;
  hasVncSasl = hasVnc && optCyrus_sasl != null;
  hasVncJpeg = hasVnc && optLibjpeg != null;
  hasVncPng = hasVnc && optLibpng != null;

  hasFdt = !isNix;

  hasRdma = optLibibverbs != null && optLibrdmacm != null;

  hasLinuxAio = stdenv.isLinux && optLibaio != null;

  hasSpice = optSpice != null && optSpice_protocol != null;

  hasNss = optNss != null && optNspr != null;

  hasOpengl = optMesa != null && optEpoxy != null;

  optLibpulseaudio = if isNix then null else shouldUsePkg libpulseaudio;
  optAlsaLib = if isNix then null else shouldUsePkg alsaLib;
  audio = concatStringsSep "," (
       optional (optSDL2 != null) "sdl"
    ++ optional (optLibpulseaudio != null) "pa"
    ++ optional (optAlsaLib != null) "alsa"
  );

  systemBinary = if stdenv.system == "x86_64-linux" then "x86_64"
    else if stdenv.system == "i686-linux" then "i386"
    else null;

  targetList = if stdenv.system == "x86_64-linux" then "x86_64-softmmu,i386-softmmu"
    else if stdenv.system == "i686-linux" then "i386-softmmu"
    else null;

  hasModules = if isNix then null else true;
in

stdenv.mkDerivation rec {
  name = "${n}${optionalString (type != null && type != "") "-${type}"}";

  src = fetchurl {
    url = "http://wiki.qemu.org/download/${n}.tar.bz2";
    sha256 = "0836gqv5zcl0xswwjcns3mlkn18lyz2fiq8rl1ihcm6cpf8vkc3j";
  };

  nativeBuildInputs = [ pkgconfig libtool perl texinfo flex bison gettext makeWrapper ];

  buildInputs = [
    python glib zlib pixman optSDL2 optGtk optVte optNcurses optCurl optBluez
    optVde2 optLibcap_ng optAttr optLibuuid optLibceph optLibxfs optLibusb
    optUsbredir optLzo optSnappy optBzip2 optLibseccomp optGlusterfs optLibssh2
    optNumactl optGperftools optLibpulseaudio optAlsaLib
  ] ++ optionals (optGnutls != null) [
    optNettle optGnutls
  ] ++ optionals hasVncSasl [
    optCyrus_sasl
  ] ++ optionals hasVncJpeg [
    optLibjpeg
  ] ++ optionals hasVncPng [
    optLibpng
  ] ++ optionals hasVirtfs [
    optLibcap
  ] ++ optionals hasRdma [
    optLibibverbs optLibrdmacm
  ] ++ optionals hasLinuxAio [
    optLibaio
  ] ++ optionals hasSpice [
    optSpice optSpice_protocol
  ] ++ optionals hasNss [
    optNss optNspr
  ] ++ optionals hasOpengl [
    optMesa optEpoxy
  ];

  enableParallelBuilding = true;

  configureFlags = [
    (mkOther                          "smbd"                "smbd")
    (mkOther                          "sysconfdir"          "/etc")
    (mkOther                          "localstatedir"       "/var")
    # Enable  debug
    # Disable strip
    # Disable werror
    # Disable stack-protector
    (mkOther                          "audio-drv-list"      audio)
    # block-drv-whitelist
    # block-drv-ro-whitelist
    # Enable  trace-backend
    # With    trace-file
    # Disable slirp
    # Enable  tcg-interpreter
    # oss-lib
    # cpu
    # Enable  gcov
    # gcov
    # Disable blobs
    # With    vss-sdk
    # With    win-sdk

    (mkEnable (!isNix)                "system"              null)
    (mkEnable (!isKvmOnly)            "user"                null)
    (mkEnable (!isKvmOnly)            "guest-base"          null)
    (mkEnable (!isNix)                "docs"                null)
    (mkEnable true                    "guest-agent"         null)
    # Enable  guest-agent-msi
    (mkEnable (!isNix)                "pie"                 null)
    (mkEnable hasModules              "modules"             null)
    (mkEnable false                   "debug-tcg"           null)
    (mkEnable false                   "debug-info"          null)
    (mkEnable false                   "sparse"              null)

    (mkEnable (optGnutls != null)     "gnutls"              null)
    (mkEnable (optSDL2 != null)       "sdl"                 null)
    (mkWith   hasSDLAbi               "sdlabi"              "2.0")
    (mkEnable (optGtk != null)        "gtk"                 null)
    # With    gtk-abi
    (mkEnable (optVte != null)        "vte"                 null)
    (mkEnable (optNcurses != null)    "curses"              null)
    (mkEnable hasVnc                  "vnc"                 null)
    (mkEnable hasVncTls               "vnc-tls"             null)
    (mkEnable hasVncSasl              "vnc-sasl"            null)
    (mkEnable hasVncJpeg              "vnc-jpeg"            null)
    (mkEnable hasVncPng               "vnc-png"             null)
    (mkEnable stdenv.isDarwin         "cocoa"               null)
    (mkEnable hasVirtfs               "virtfs"              null)
    (mkEnable false                   "xen"                 null)
    (mkEnable false                   "xen-pci-passthrough" null)
    (mkEnable false                   "brlapi"              null)
    (mkEnable (optCurl != null)       "curl"                null)
    (mkEnable hasFdt                  "fdt"                 null)
    (mkEnable (optBluez != null)      "bluez"               null)
    (mkEnable stdenv.isLinux          "kvm"                 null)
    (mkEnable hasRdma                 "rdma"                null)
    (mkEnable (optLibuuid != null)    "uuid"                null)
    (mkEnable (optVde2 != null)       "vde"                 null)
    (mkEnable false                   "netmap"              null)  # TODO(wkennington): Add Support
    (mkEnable hasLinuxAio             "linux-aio"           null)
    (mkEnable (optLibcap_ng != null)  "cap-ng"              null)
    (mkEnable (optAttr != null)       "attr"                null)
    (mkEnable stdenv.isLinux          "vhost-net"           null)
    (mkEnable hasSpice                "spice"               null)
    (mkEnable (optLibceph != null)    "rbd"                 null)
    (mkEnable false                   "libiscsi"            null)  # TODO(wkennington): Add support
    (mkEnable false                   "libnfs"              null)  # TODO(wkennington): Add support
    (mkEnable hasNss                  "smartcard-nss"       null)
    (mkEnable (optLibusb != null)     "libusb"              null)
    (mkEnable (optUsbredir != null)   "usb-redir"           null)
    (mkEnable (optLzo != null)        "lzo"                 null)
    (mkEnable (optSnappy != null)     "snappy"              null)
    (mkEnable (optBzip2 != null)      "bzip2"               null)
    (mkEnable (optLibseccomp != null) "seccomp"             null)
    (mkEnable true                    "coroutine-pool"      null)
    (mkEnable (optGlusterfs != null)  "glusterfs"           null)
    (mkEnable false                   "archipelago"         null)
    (mkEnable true                    "tpm"                 null)
    (mkEnable (optLibssh2 != null)    "libssh2"             null)
    (mkEnable (optLibuuid != null)    "vhdx"                null)
    (mkEnable (optNumactl != null)    "numa"                null)
    (mkEnable (optGperftools != null) "tcmalloc"            null)

    (mkEnable hasOpengl               "opengl"              null)
    (mkEnable (optLibxfs != null)     "xfsctl"              null)
  ] ++ optionals isKvmOnly [
    (mkOther                          "target-list"         targetList)
  ] ++ optionals isNix [
    (mkOther                          "static"              null)
  ];

  installFlags = [
    "sysconfdir=\${out}/etc"
    "qemu_confdir=\${out}/etc/qemu"
    "qemu_localstatedir=\${TMPDIR}"
  ];

  postInstall = optionalString (systemBinary != null) ''
    # Add a ‘qemu-kvm’ wrapper for compatibility/convenience.
    p="$out/bin/qemu-system-${systemBinary}"
    if [ -e "$p" ]; then
      makeWrapper "$p" $out/bin/qemu-kvm --add-flags "\$([ -e /dev/kvm ] && echo -enable-kvm)"
    fi
  '';

  meta = with stdenv.lib; {
    homepage = http://www.qemu.org/;
    description = "A generic and open source machine emulator and virtualizer";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ viric shlevy eelco wkennington ];
    platforms = if isKvmOnly then platforms.linux else platforms.all;
  };
}
