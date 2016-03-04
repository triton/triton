{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool

, dbus-glib
, gtk3
, libgnome-keyring
, libsecret
, networkmanager
, networkmanager-applet
, ppp
, pptp
}:

stdenv.mkDerivation rec {
  name = "NetworkManager-pptp-${version}";
  versionMajor = "1.0";
  versionMinor = "8";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/NetworkManager-pptp/${versionMajor}/"
        + "${name}.tar.xz";
    sha256 = "0k1416p2378clq1kkahk2ngrja84zwrmblfgg7vr1n3hy6x33w3g";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    dbus-glib
    gtk3
    libsecret
    networkmanager
    networkmanager-applet
    ppp
    pptp
  ];

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "networkmanager/pptp-purity.patch";
      sha256 = "8d3359767c1acb8cf36eff094763b8f9ce0a860e2b20f585e0922ee2c4750c23";
    })
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-more-warnings"
    #"--with-pppd-plugin-dir"
    "--with-gnome"
  ];

  postConfigure = ''
    sed -i Makefile */Makefile \
      -e 's/-Werror//g'
  '';

  meta = with stdenv.lib; {
    description = "NetworkManager PPTP plugin";
    homepage = https://wiki.gnome.org/Projects/NetworkManager;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
