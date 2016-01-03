{ stdenv, fetchurl, gtk, gtkspell, aspell
, gstreamer, gst_plugins_base, startupnotification, gettext
, perl, perlXMLParser, libxml2, nss, nspr, farsight2
, xorg, ncurses, avahi, dbus, dbus_glib, intltool, libidn
, lib, python
, openssl ? null
, gnutls ? null
, libgcrypt ? null
}:

# FIXME: clean the mess around choosing the SSL library (nss by default)

stdenv.mkDerivation rec {
  name = "pidgin-${version}";
  majorVersion = "2";
  version = "${majorVersion}.10.12";

  src = fetchurl {
    url = "mirror://sourceforge/pidgin/${name}.tar.bz2";
    sha256 = "1pgzfwgf7vl72hppdr2v8gd8dlbvkymkidxj0ff792gyzvq26x9c";
  };

  inherit nss ncurses;

  buildInputs = [
    gtkspell aspell
    gstreamer gst_plugins_base startupnotification
    libxml2 nss nspr farsight2
    xorg.libXScrnSaver ncurses python
    avahi dbus dbus_glib intltool libidn
    xorg.libICE xorg.libXext xorg.libSM
  ]
  ++ (lib.optional (openssl != null) openssl)
  ++ (lib.optional (gnutls != null) gnutls)
  ++ (lib.optional (libgcrypt != null) libgcrypt);

  propagatedBuildInputs = [
    gtk perl perlXMLParser gettext
  ];

  patches = [./pidgin-makefile.patch ./add-search-path.patch ];

  configureFlags = [
    "--with-nspr-includes=${nspr}/include/nspr"
    "--with-nspr-libs=${nspr}/lib"
    "--with-nss-includes=${nss}/include/nss"
    "--with-nss-libs=${nss}/lib"
    "--with-ncurses-headers=${ncurses}/include"
    "--disable-meanwhile"
    "--disable-nm"
    "--disable-tcl"
  ]
  ++ (lib.optionals (gnutls != null) ["--enable-gnutls=yes" "--enable-nss=no"]);

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Multi-protocol instant messaging client";
    homepage = http://pidgin.im;
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [ maintainers.vcunat ];
  };
}
