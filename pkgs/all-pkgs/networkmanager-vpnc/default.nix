{ stdenv
, fetchurl
, intltool
, module_init_tools
, procps

, dbus_glib
, glib
, gtk3
, libsecret
, networkmanager
, networkmanager-applet
, vpnc
}:

with {
  inherit (stdenv.lib)
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "NetworkManager-vpnc-${version}";
  versionMajor = "1.0";
  versionMinor = "8";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/NetworkManager-vpnc/${versionMajor}/"
        + "${name}.tar.xz";
    sha256 = "0vmnjbxnzars0w3k94kcks0zjaqhcg12w8czq92jijrckvc38h2y";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    dbus_glib
    glib
    gtk3
    libsecret
    networkmanager
    networkmanager-applet
    vpnc
  ];

  preConfigure = ''
     substituteInPlace "configure" \
       --replace "/sbin/sysctl" "${procps}/sbin/sysctl"
     substituteInPlace "src/nm-vpnc-service.c" \
       --replace "/sbin/vpnc" "${vpnc}/sbin/vpnc" \
       --replace "/sbin/modprobe" "${module_init_tools}/sbin/modprobe"
  '';

  configureFlags = [
    "--enable-maintainer-mode"
    "--enable-nls"
    "--enable-more-warnings"
    (wtFlag "gnome" (
      gtk3 != null
      && networkmanager-applet != null
      && libsecret != null) null)
    (wtFlag "tests" doCheck null)
  ];

  postConfigure = ''
     substituteInPlace "./auth-dialog/Makefile" \
       --replace "-Wstrict-prototypes" "" \
       --replace "-Werror" ""
     substituteInPlace "properties/Makefile" \
       --replace "-Wstrict-prototypes" "" \
       --replace "-Werror" ""
  '';

  doCheck = false;

  meta = with stdenv.lib; {
    description = "NetworkManager VPNC plugin";
    homepage = https://wiki.gnome.org/Projects/NetworkManager;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
