{ stdenv
, bison
, fetchurl
, flex
, gettext
, iasl
, perl
, python

, acl
, alsa-lib
, bluez
, bzip2
, ceph_lib
, curl
, cyrus-sasl
, dtc
, glib
, glusterfs
, gnutls
, gtk
, jemalloc
, libaio
, libcacard
, libcap
, libcap-ng
, libdrm
, libepoxy
, libiscsi
, libjpeg
, libnfs
, libpng
, libseccomp
, libssh2
, libtasn1
, libusb
, libx11
, lzo
, numactl
, ncurses
, opengl-dummy
, pulseaudio_lib
, rdma-core
, sdl
, snappy
, spice
, spice-protocol
, texinfo
, usbredir
, util-linux_lib
, vde2
, virglrenderer
, vte
, xfsprogs_lib
, xorg
, xorgproto
, zlib
}:

stdenv.mkDerivation rec {
  name = "qemu-2.10.1";

  src = fetchurl {
    url = "http://wiki.qemu-project.org/download/${name}.tar.bz2";
    multihash = "QmNjp2xNu4xU6jJZ9DpknWENsbzZPrxWHHVG3HZcKxi5Y9";
    hashOutput = false;
    sha256 = "8e040bc7556401ebb3a347a8f7878e9d4028cf71b2744b1a1699f4e741966ba8";
  };

  nativeBuildInputs = [
    bison
    flex
    gettext
    iasl
    perl
    python
    texinfo
  ];

  buildInputs = [
    acl
    alsa-lib
    bluez
    bzip2
    ceph_lib
    curl
    cyrus-sasl
    dtc
    glib
    glusterfs
    gnutls
    gtk
    jemalloc
    libaio
    libcacard
    libcap
    libcap-ng
    libdrm
    libepoxy
    libiscsi
    libjpeg
    libnfs
    libpng
    libseccomp
    libssh2
    libtasn1
    libusb
    libx11
    lzo
    numactl
    ncurses
    opengl-dummy
    pulseaudio_lib
    rdma-core
    sdl
    snappy
    spice
    spice-protocol
    usbredir
    util-linux_lib
    vde2
    virglrenderer
    vte
    xfsprogs_lib
    xorg.pixman
    xorgproto
    zlib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--audio-drv-list=alsa,sdl,pa"  # TODO: oss
    "--enable-system"
    "--enable-user"
    "--enable-docs"
    "--disable-guest-agent"
    "--disable-guest-agent-msi"
    "--enable-modules"
    "--enable-jemalloc"
  ];

  # We can't enable stack protector on firmware code
  stackProtector = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "CEAC C9E1 5534 EBAB B82D  3FA0 3353 C9CE F108 B584";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
