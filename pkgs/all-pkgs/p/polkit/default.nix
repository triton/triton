{ stdenv
, autoconf
, automake
, docbook_xml_dtd_412
, docbook-xsl
, fetchzip
, gtk-doc
, intltool
, libtool
, libxslt

, glib
, expat
, pam
, spidermonkey_24
, gobject-introspection
, systemd_lib
}:

let
  date = "2016-12-12";
  rev = "3272a988655c3236b55bad70e9a3af20857f384b";
in
stdenv.mkDerivation rec {
  name = "polkit-${date}";

  src = fetchzip {
    version = 2;
    url = "https://cgit.freedesktop.org/polkit/snapshot/${rev}.tar.xz";
    multihash = "Qmba7Ei5AJTci1cDevcGmqVSdnboyQf2h9bXBzbQzCEV9b";
    sha256 = "877444a34b99d32f44acd9c8d8e65fc3281c632b0177358babe0ce916252f636";
  };

  nativeBuildInputs = [
    autoconf
    automake
    docbook_xml_dtd_412
    docbook-xsl
    gtk-doc
    intltool
    libtool
    libxslt
  ];

  buildInputs = [
    glib
    expat
    pam
    spidermonkey_24
    gobject-introspection
    systemd_lib
  ];

  postPatch = ''
    patchShebangs .

    # Get rid of a check to see if systemd is running to allow libsystemd linking
    sed '/does not.*systemd/s/.*/:/' -i configure.ac

    # polkit-agent-helper-1 is a setuid binary so remap the path in the codebase.
    sed -i 's,PACKAGE_PREFIX "/lib/polkit-1,"/var/setuid-wrappers,g' \
      src/polkitagent/polkitagentsession.c
  '';

  preConfigure = ''
    NOCONFIGURE=1 ./autogen.sh

    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--datarootdir=/run/current-system/sw/share"
    "--with-polkitd-user=polkit"
    "--with-os-type=NixOS" # not recognized but prevents impurities on non-NixOS
    "--enable-introspection"
    "--disable-examples"
    "--disable-test"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "datarootdir=$out/share"
      "INTROSPECTION_GIRDIR=$out/share/gir-1.0"
      "INTROSPECTION_TYPELIBDIR=$out/lib/girepository-1.0"
    )
  '';

  parallelInstall = false;

  meta = with stdenv.lib; {
    homepage = http://www.freedesktop.org/wiki/Software/polkit;
    description = "A toolkit for defining and handling the policy that allows unprivileged processes to speak to privileged processes";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
