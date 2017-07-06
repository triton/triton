{ stdenv
, docbook_xml_dtd_43
, docbook-xsl
, fetchurl
, intltool
, libxslt

, acl
, glib
, gobject-introspection
, gnused
, libatasmart
, libblockdev
, libconfig
, libgudev
, libstoragemgmt
, lvm2
, mdadm
, polkit
, systemd_lib
, util-linux_full
}:

stdenv.mkDerivation rec {
  name = "udisks-2.7.1";

  src = fetchurl {
    url = "https://github.com/storaged-project/udisks/releases/download/${name}/${name}.tar.bz2";
    sha256 = "449150e13716d5fce512997142e696dfc8ab0985dc04f9a94c66bb8e8b749c12";
  };

  postPatch = ''
    # We need to fix the default path inside of udisks
    grep -q '"/usr/bin:/bin:/usr/sbin:/sbin"' src/main.c
    sed -i 's,"/usr/bin:/bin:/usr/sbin:/sbin","/run/current-system/sw/bin",g' src/main.c

    # We need to fix the udev rules
    grep -q '/bin/sh' data/80-udisks2.rules
    grep -q '/bin/sed' data/80-udisks2.rules
    grep -q '/sbin/mdadm' data/80-udisks2.rules
    sed \
      -e 's,/bin/sh,${stdenv.shell},g' \
      -e 's,/bin/sed,${gnused}/bin/sed,g' \
      -e 's,/sbin/mdadm,${mdadm}/bin/mdadm,g' \
      -i data/80-udisks2.rules

    # We need to fix uses of BUILD_DIR
    find . -name \*.c -exec sed -i 's,BUILD_DIR,"/no-such-path",g' {} \;
  '';

  nativeBuildInputs = [
    docbook_xml_dtd_43
    docbook-xsl
    intltool
    libxslt
  ];

  buildInputs = [
    acl
    glib
    libatasmart
    libblockdev
    libconfig
    libgudev
    libstoragemgmt
    lvm2
    polkit
    systemd_lib
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
      "--with-udevdir=$out/lib/udev"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-gtk-doc"
    "--enable-man"
    "--enable-lvm2"
    "--enable-lvmcache"
    #"--enable-iscsi"  # TODO: Enable
    "--enable-btrfs"
    "--enable-zram"
    "--enable-lsm"
    "--enable-bcache"
    "--with-modloaddir=/etc/modules-load.d"
    "--with-modprobedir=/etc/modprobe.d"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
    )
  '';

  meta = with stdenv.lib; {
    homepage = http://www.freedesktop.org/wiki/Software/udisks;
    description = "A daemon and command-line utility for querying and manipulating storage devices";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
