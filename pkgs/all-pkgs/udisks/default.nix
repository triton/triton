{ stdenv
, docbook_xml_dtd_43
, docbook_xsl
, fetchurl
, intltool
, libxslt

, acl
, systemd_lib
, glib
, gobject-introspection
, gnused
, libatasmart
, polkit
, util-linux_full
, libgudev
}:

stdenv.mkDerivation rec {
  name = "udisks-2.1.7";

  src = fetchurl {
    url = "http://udisks.freedesktop.org/releases/${name}.tar.bz2";
    sha256 = "119pr2zbff8vkwlhghim7d7ir24c1dil9hp4q49wm4f6pnrjpbmb";
  };

  # FIXME remove /var/run/current-system/sw/* references
  # FIXME add references to parted, cryptsetup, etc (see the sources)
  postPatch = ''
    # We need to fix the default path inside of udisks
    grep -q '"/usr/bin:/bin:/usr/sbin:/sbin"' src/main.c
    sed -i 's,"/usr/bin:/bin:/usr/sbin:/sbin","/run/current-system/sw/bin",g' src/main.c

    # We need to fix the udev rules
    grep -q '/bin/sh' data/80-udisks2.rules
    grep -q 'sed' data/80-udisks2.rules
    sed \
      -e 's,/bin/sh,${stdenv.shell},g' \
      -e 's,sed,${gnused}/bin/sed,g' \
      -i data/80-udisks2.rules
  '';

  nativeBuildInputs = [
    docbook_xml_dtd_43
    docbook_xsl
    intltool
    libxslt
  ];

  buildInputs = [
    acl
    glib
    gobject-introspection
    libatasmart
    libgudev
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
  ];

  preBuild = ''
    INTROSPECTION_TYPELIBDIR="$(grep -r 'INTROSPECTION_TYPELIBDIR = ' udisks/Makefile | awk -F'= ' '{print $2}')"
    INTROSPECTION_GIRDIR="$(grep -r 'INTROSPECTION_GIRDIR = ' udisks/Makefile | awk -F'= ' '{print $2}')"
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "INTROSPECTION_TYPELIBDIR=$(echo "$INTROSPECTION_TYPELIBDIR" | sed "s,${gobject-introspection},$out,g")"
      "INTROSPECTION_GIRDIR=$(echo "$INTROSPECTION_GIRDIR" | sed "s,${gobject-introspection},$out,g")"
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
