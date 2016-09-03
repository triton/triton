{ stdenv
, fetchurl
, gettext
, intltool
, kmod
, procps

, dbus-glib
, glib
, gtk3
, libsecret
, networkmanager
, networkmanager-applet
, openvpn
}:

let
  inherit (stdenv.lib)
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "NetworkManager-openvpn-${version}";
  versionMajor = "1.0";
  versionMinor = "8";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/NetworkManager-openvpn/${versionMajor}/"
        + "${name}.tar.xz";
    sha256 = "1b0ji6krnj6f149ajg7flx693b9znp2mcj4xfa7dg91bswcrb5qv";
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
    networkmanager
    networkmanager-applet
    openvpn
  ];

  preConfigure = ''
     substituteInPlace "configure" \
       --replace "/sbin/sysctl" "${procps}/sbin/sysctl"
     substituteInPlace "src/nm-openvpn-service.c" \
       --replace "/sbin/openvpn" "${openvpn}/sbin/openvpn" \
       --replace "/sbin/modprobe" "${kmod}/sbin/modprobe"
     substituteInPlace "properties/auth-helpers.c" \
       --replace "/sbin/openvpn" "${openvpn}/sbin/openvpn"
  '';

  configureFlags = [
  "--localstatedir=/"
  "--disable-maintainer-mode"
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
    description = "NetworkManager OpenVPN plugin";
    homepage = https://wiki.gnome.org/Projects/NetworkManager;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
