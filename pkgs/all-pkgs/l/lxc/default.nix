{ stdenv
, autoconf
, automake
, fetchurl
, docbook2x
, docbook_xml_dtd_45

, cgmanager
, dbus
, gnutls
, libcap
, libnih
, libselinux
, libseccomp
}:

let
  version = "2.1.0";
in
stdenv.mkDerivation rec {
  name = "lxc-${version}";

  src = fetchurl {
    url = "https://linuxcontainers.org/downloads/lxc/lxc-${version}.tar.gz";
    multihash = "QmfUMfD5dd9afbfsdeWoXy9RDmpjMZybgNF6zECNNQt5CT";
    hashOutput = false;
    sha256 = "394407305a409eb1f95fe06e7718acfe89b1d5df267b0c6aafb1d714e2038de2";
  };

  nativeBuildInputs = [
    autoconf
    automake
    docbook2x
  ];

  buildInputs = [
    cgmanager
    dbus
    gnutls
    libcap
    libnih
    libseccomp
    libselinux
  ];

  XML_CATALOG_FILES = "${docbook_xml_dtd_45}/xml/dtd/docbook/catalog.xml";

  patches = [
    ./support-db2x.patch
  ];

  postPatch = ''
    # Can't setuid in a nixbuild
    sed -i 's,chmod u+s.*,true,' src/lxc/Makefile.{am,in}
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-werror"
    "--enable-rpath"
    "--enable-doc"
    "--disable-api-docs"
    "--with-init-script=none"
    "--with-distro=nixos" # just to be sure it is "unknown"
    "--disable-apparmor"
    "--enable-gnutls"
    "--enable-selinux"
    "--enable-seccomp"
    "--enable-cgmanager"
    "--enable-capabilities"
    "--disable-examples"
    "--disable-python"
    "--disable-lua"
    "--disable-bash"
    "--with-rootfs-path=/var/lib/lxc/rootfs"
  ];

  installFlags = [
    "localstatedir=\${TMPDIR}"
    "sysconfdir=\${out}/etc"
    "sysconfigdir=\${out}/etc/default"
    "bashcompdir=\${out}/share/bash_completion.d" # FIXME
    "READMEdir=\${TMPDIR}/var/lib/lxc/rootfs"
    "LXCPATH=\${TMPDIR}/var/lib/lxc"
  ];

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
