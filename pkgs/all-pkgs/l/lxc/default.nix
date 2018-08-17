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
  version = "3.0.2";
in
stdenv.mkDerivation rec {
  name = "lxc-${version}";

  src = fetchurl {
    url = "https://linuxcontainers.org/downloads/lxc/lxc-${version}.tar.gz";
    multihash = "QmfGbRQruUpZchEoAT4sna9viCUn1o28ZTU8s3YME9azLi";
    hashOutput = false;
    sha256 = "6ab7117b17066220da450c55ed77953998cf2336d415143b879554364af12f5c";
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
