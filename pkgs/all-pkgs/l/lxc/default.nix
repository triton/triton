{ stdenv
, autoreconfHook
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
  version = "2.1.1";
in
stdenv.mkDerivation rec {
  name = "lxc-${version}";

  src = fetchurl {
    url = "https://linuxcontainers.org/downloads/lxc/lxc-${version}.tar.gz";
    multihash = "QmS6WAPq5RrvtWuv2c49vzp1WdvE2QUSJdL4tymBcyB6sZ";
    hashOutput = false;
    sha256 = "68663a67450a8d6734e137eac54cc7077209fb15c456eec401a2c26e6386eff6";
  };

  nativeBuildInputs = [
    autoreconfHook
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
