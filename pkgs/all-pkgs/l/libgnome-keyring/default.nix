{ stdenv
, fetchurl
, gettext
, intltool

, dbus
, glib
, gnome-keyring
, gobject-introspection
, libgcrypt
, vala
}:

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "libgnome-keyring-${version}";
  versionMajor = "3.12";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/libgnome-keyring/${versionMajor}/"
        + "${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/libgnome-keyring/${versionMajor}/"
              + "${name}.sha256sum";
    sha256 = "c4c178fbb05f72acc484d22ddb0568f7532c409b0a13e06513ff54b91e947783";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    dbus
    glib
    gnome-keyring
    gobject-introspection
    libgcrypt
    vala
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
    "--disable-debug"
    "--disable-coverage"
  ];

  meta = with stdenv.lib; {
    description = "Compatibility library for accessing secrets";
    homepage = https://wiki.gnome.org/Projects/GnomeKeyring;
    license = with licenses; [
      gpl2Plus
      lgpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
