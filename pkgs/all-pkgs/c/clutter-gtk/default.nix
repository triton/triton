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
    boolEn;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "clutter-gtk-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/clutter-gtk/${channel}/${name}.tar.xz";
    hashOutput = false;
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
    "--${boolEn (gobject-introspection != null)}-introspection"
  ];

  postBuild = "rm -frv $out/share/gtk-doc";

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/clutter-gtk/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

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
