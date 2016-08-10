{ stdenv
, docbook_xml_dtd_412
, docbook-xsl
, fetchurl
, intltool
, libxslt

, glib
, expat
, pam
, spidermonkey_17
, gobject-introspection
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "polkit-0.113";

  src = fetchurl {
    url = "http://www.freedesktop.org/software/polkit/releases/${name}.tar.gz";
    sha256 = "109w86kfqrgz83g9ivggplmgc77rz8kx8646izvm2jb57h4rbh71";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_412
    docbook-xsl
    intltool
    libxslt
  ];

  buildInputs = [
    glib
    expat
    pam
    spidermonkey_17
    gobject-introspection
    systemd_lib
  ];

  postPatch = ''
    patchShebangs .

    # Get rid of a check to see if systemd is running to allow libsystemd linking
    sed '/libsystemd autoconfigured/s/.*/:/' -i configure

    # polkit-agent-helper-1 is a setuid binary so remap the path in the codebase.
    sed -i 's,PACKAGE_PREFIX "/lib/polkit-1,"/var/setuid-wrappers,g' \
      src/polkitagent/polkitagentsession.c
  '';

  preConfigure = ''
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
