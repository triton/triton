{ stdenv
, docbook_xml_dtd_43
, docbook-xsl
, fetchurl
, intltool
, lib
, libxslt
, makeWrapper

, acl
, dosfstools
, e2fsprogs
, glib
, gobject-introspection
, gnused
, gptfdisk
, libatasmart
, libblockdev
, libconfig
, libgudev
, libstoragemgmt
, lvm2
, mdadm
, ntfs-3g
, polkit
, systemd_lib
, util-linux_full
, xfsprogs
}:

stdenv.mkDerivation rec {
  name = "udisks-2.7.6";

  src = fetchurl {
    url = "https://github.com/storaged-project/udisks/releases/download/"
      + "${name}/${name}.tar.bz2";
    sha256 = "512da29063de1cd4ecbfd9182d4faea0aff40835eaac69bc9f08e20ec56d16fe";
  };

  # FIXME:
  # - hard coded path in etc/systemd/system/zram-setup@.service
  postPatch = ''
    # We need to fix the default path inside of udisks
    grep -q '"/usr/bin:/bin:/usr/sbin:/sbin"' src/main.c
    sed -i  src/main.c \
      -e 's,"/usr/bin:/bin:/usr/sbin:/sbin","/run/current-system/sw/bin",g'

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
    makeWrapper
  ];

  buildInputs = [
    acl
    glib
    gobject-introspection
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
    "--enable-introspection"
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
      "girdir=$out/share/gir-1.0"
      "typelibsdir=$out/lib/girepository-1.0"
    )
  '';

  preFixup = ''
    wrapProgram $out/libexec/udisks2/udisksd \
      --prefix 'PATH' : "${dosfstools}/bin" \
      --prefix 'PATH' : "${e2fsprogs}/bin" \
      --prefix 'PATH' : "${gptfdisk}/bin" \
      --prefix 'PATH' : "${lvm2}/bin" \
      --prefix 'PATH' : "${mdadm}/bin" \
      --prefix 'PATH' : "${ntfs-3g}/bin" \
      --prefix 'PATH' : "${util-linux_full}/bin" \
      --prefix 'PATH' : "${xfsprogs}/bin"
  '';

  meta = with lib; {
    homepage = http://www.freedesktop.org/wiki/Software/udisks;
    description = "Daemon & cli utility for querying & manipulating storage devices";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
