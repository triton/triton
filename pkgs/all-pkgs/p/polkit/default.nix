{ stdenv
, autoconf
, automake
, docbook_xml_dtd_412
, docbook-xsl
, fetchzip
, gtk-doc
, intltool
, lib
, libtool
, libxslt

, glib
, expat
, pam
, spidermonkey_52
, gobject-introspection
, systemd_lib
}:

let
  date = "2018-04-03";
  rev = "dda431905221a81921492b1d28b96b4bffb57700";
in
stdenv.mkDerivation rec {
  name = "polkit-${date}";

  src = fetchzip {
    version = 6;
    url = "https://cgit.freedesktop.org/polkit/snapshot/${rev}.tar.xz";
    multihash = "Qma5P1infsj9vQ8rsNFoU66YKwLDxcp8c5DoFrBfYR5q5v";
    sha256 = "20f577d2f9ee618f8f8e3b9035a402bd4cac68026be186f8b7d12d267fcacffa";
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
    spidermonkey_52
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

  installParallel = false;

  meta = with lib; {
    homepage = http://www.freedesktop.org/wiki/Software/polkit;
    description = "A toolkit for defining and handling the policy that allows unprivileged processes to speak to privileged processes";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
