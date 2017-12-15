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
  date = "2017-04-24";
  rev = "766a2eab6bfedc9df00b0509bc34ccdee9fe0a76";
in
stdenv.mkDerivation rec {
  name = "polkit-${date}";

  src = fetchzip {
    version = 3;
    url = "https://cgit.freedesktop.org/polkit/snapshot/${rev}.tar.xz";
    multihash = "QmaRi4JCEz7SZhSwARy4iFUeHe9CisUcpHo6XcmjuzdejC";
    sha256 = "1db5e8fe9d74a538d46b5eb8dbe00bdf2d6dd3dade9f51869d3599cb3be33fa0";
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

  installParallel = false;

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
