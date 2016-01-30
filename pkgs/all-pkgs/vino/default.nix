{ stdenv
, fetchurl
, intltool

, adwaita-icon-theme
, avahi
, dbus_glib
, file
, glib
, gnutls
, gtk3
, libgcrypt
, libjpeg
, libnotify
, libsecret
, libsoup
, telepathy_glib
, xorg
, zlib
}:

stdenv.mkDerivation rec {
  name = "vino-${version}";
  versionMajor = "3.18";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/vino/${versionMajor}/${name}.tar.xz";
    sha256 = "0npyzabbk0v4qdxd22dv89v9rnpx69lv4gl7rqzyxm7cpdw6xv07";
  };

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-compile-warnings"
    "--disable-debug"
    "--enable-nls"
    "--enable-ipv6"
    "--enable-schemas-compile"
    "--with-telepathy"
    "--with-secret"
    "--with-x"
    "--with-gnutls"
    "--with-gcrypt"
    "--with-avahi"
    "--with-zlib"
    "--with-jpeg"
  ];

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    adwaita-icon-theme
    avahi
    dbus_glib
    file
    glib
    gnutls
    gtk3
    libgcrypt
    libjpeg
    libnotify
    libsecret
    libsoup
    telepathy_glib
    xorg.libSM
    xorg.libX11
    zlib
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "GNOME desktop sharing server";
    homepage = https://wiki.gnome.org/action/show/Projects/Vino;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
