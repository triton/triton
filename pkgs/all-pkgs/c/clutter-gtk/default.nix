{ stdenv
, fetchurl
, gettext

, atk
, clutter
, cogl
, gdk-pixbuf
, glib
, gobject-introspection
, gtk3
, json-glib
, pango

, channel
}:

let
  inherit (stdenv.lib)
    enFlag;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "clutter-gtk-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/clutter-gtk/${channel}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/clutter-gtk/${channel}/"
      + "${name}.sha256sum";
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    atk
    cogl
    clutter
    gdk-pixbuf
    glib
    gobject-introspection
    gtk3
    json-glib
    pango
  ];

  configureFlags = [
    "--disable-deprecated"
    "--disable-debug"
    "--disable-maintainer-flags"
    "--enable-nls"
    "--enable-rpath"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
  ];

  postBuild = "rm -frv $out/share/gtk-doc";

  meta = with stdenv.lib; {
    description = "Library for embedding a Clutter canvas (stage) in GTK+";
    homepage = http://www.clutter-project.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
