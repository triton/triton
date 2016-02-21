{ stdenv
, fetchurl

, atk
, clutter
, cogl
, gdk-pixbuf
, glib
, gobject-introspection
, gst-plugins-base
, gstreamer
, gtk3
, json-glib
, pango
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "clutter-gst-${version}";
  versionMajor = "3.0";
  versionMinor = "16";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/clutter-gst/${versionMajor}/${name}.tar.xz";
    sha256 = "1w7rm8n4b6vskrg537rfa58ykpwj8w3cdl0zwa0hagp6cmr8ngl0";
  };

  buildInputs = [
    atk
    clutter
    cogl
    gdk-pixbuf
    glib
    gobject-introspection
    gst-plugins-base
    gstreamer
    gtk3
    json-glib
    pango
  ];

  configureFlags = [
    "--enable-gl-texture-upload"
    "--disable-maintainer-flags"
    "--disable-debug"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
  ];

  postBuild = "rm -rvf $out/share/gtk-doc";

  meta = with stdenv.lib; {
    description = "GStreamer bindings for clutter";
    homepage = http://www.clutter-project.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
