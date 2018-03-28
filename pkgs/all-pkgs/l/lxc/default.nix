{ stdenv
, fetchurl
, docbook2x
, docbook_xml_dtd_45

, gnutls
, libcap
, libselinux
, libseccomp
, pam
}:

let
  version = "3.0.0";
in
stdenv.mkDerivation rec {
  name = "lxc-${version}";

  src = fetchurl {
    url = "https://linuxcontainers.org/downloads/lxc/lxc-${version}.tar.gz";
    multihash = "QmSDiZSpg9GPHa9eXVYoSrwbWU7KLKEDyN3ix87j3axwQk";
    hashOutput = false;
    sha256 = "6230224c27f050201b372b18a9f39cd220ed584899c5f0cf73c6b313dabc8d8a";
  };

  nativeBuildInputs = [
    docbook2x
  ];

  buildInputs = [
    gnutls
    libcap
    libseccomp
    libselinux
    pam
  ];

  XML_CATALOG_FILES = "${docbook_xml_dtd_45}/xml/dtd/docbook/catalog.xml";

  postPatch = ''
    # We never want to build static binaries
    grep -q '@HAVE_STATIC_LIBCAP_TRUE@.*init.lxc.static' src/lxc/Makefile.in
    sed -i 's,@HAVE_STATIC_LIBCAP_TRUE@,#,' src/lxc/Makefile.in

    # Never setuid
    grep -q 'chmod u+s' src/lxc/Makefile.in
    sed -i '/chmod u+s/d' src/lxc/Makefile.in

    # Fix docbook usage
    grep -q 'Davenport' configure
    sed -i 's,xdocbook2man,xno-such-program,' configure
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-werror"
    "--enable-rpath"
    "--enable-doc"
    "--disable-api-docs"
    "--disable-apparmor"
    "--enable-gnutls"
    "--enable-selinux"
    "--enable-seccomp"
    "--enable-capabilities"
    "--disable-examples"
    "--disable-bash"
    "--enable-pam"
    "--with-rootfs-path=/var/lib/lxc/rootfs"
    "--with-init-script=systemd"
    "--with-distro=triton" # just to be sure it is "unknown"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "sysconfigdir=$out/etc/default"
      "configdir=$out/etc/lxc"
      "localstatedir=$TMPDIR"
      "SYSTEMD_UNIT_DIR=$out/lib/systemd/system"
      "READMEdir=$TMPDIR"
      "LXCPATH=$TMPDIR"
    )
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "602F 5676 63E5 93BC BD14  F338 C638 974D 6479 2D67";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = "http://lxc.sourceforge.net";
    description = "userspace tools for Linux Containers, a lightweight virtualization system";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
