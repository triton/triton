{ stdenv
, fetchurl
, gettext

, glib
, gobject-introspection
, gtk3
, libsoup
, vala
}:

let
  inherit (stdenv.lib)
    enFlag
    wtFlag;
in
stdenv.mkDerivation rec {
  name = "gssdp-${version}";
  versionMajor = "0.14";
  versionMinor = "16";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/gssdp/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/gssdp/${versionMajor}/"
      + "${name}.sha256sum";
    sha256 = "54520bfb230b9c8c938eba88d87df44e04749682c95fb8aa381d13441345c5b2";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    glib
    gobject-introspection
    gtk3
    libsoup
    vala
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-compile-warnings"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (wtFlag "gtk" (gtk3 != null) null)
  ];

  meta = with stdenv.lib; {
    description = "GObject-based API for resource discovery and announcement over SSDP";
    homepage = https://wiki.gnome.org/Projects/GUPnP;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
