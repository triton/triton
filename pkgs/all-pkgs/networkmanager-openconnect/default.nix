{ stdenv
, fetchurl
, gettext
, intltool
, module_init_tools
, procps

, dbus-glib
, glib
, gtk3
, libsecret
, libxml2
, networkmanager
, openconnect
}:

with {
  inherit (stdenv.lib)
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "NetworkManager-openconnect-${version}";
  versionMajor = "1.0";
  versionMinor = "8";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/NetworkManager-openconnect/${versionMajor}/"
        + "${name}.tar.xz";
    sha256 = "1rnp0qj33y4yz51ww88k7ncmfvxims66r3ldx4ky7jmczy22igy1";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    dbus-glib
    glib
    gtk3
    libsecret
    libxml2
    networkmanager
    openconnect
  ];

  preConfigure = ''
     substituteInPlace "configure" \
       --replace "/sbin/sysctl" "${procps}/sbin/sysctl"
     substituteInPlace "src/nm-openconnect-service.c" \
       --replace "/usr/sbin/openconnect" "${openconnect}/sbin/openconnect" \
       --replace "/sbin/modprobe" "${module_init_tools}/sbin/modprobe"
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-more-warnings"
    (wtFlag "gnome" (
      gtk3 != null
      && libsecret != null) null)
    (wtFlag "authdlg" (
      gtk3 != null
      && libsecret != null
      && openconnect != null) null)
  ];

  postConfigure = ''
     substituteInPlace "./auth-dialog/Makefile" \
       --replace "-Wstrict-prototypes" "" \
       --replace "-Werror" ""
     substituteInPlace "properties/Makefile" \
       --replace "-Wstrict-prototypes" "" \
       --replace "-Werror" ""
  '';

  meta = with stdenv.lib; {
    description = "NetworkManager OpenConnect plugin";
    homepage = https://wiki.gnome.org/Projects/NetworkManager;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
