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
, libgudev
, pango
}:

let
  inherit (stdenv.lib)
    enFlag;
in
stdenv.mkDerivation rec {
  name = "clutter-gst-${version}";
  versionMajor = "3.0";
  versionMinor = "18";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/clutter-gst/${versionMajor}/${name}.tar.xz";
    sha256 = "0aec0d0c6020cd19a5bb0dab1165a92748f81a9a3acdfabb0f966d5f53bc8093";
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
    libgudev
    pango
  ];

  configureFlags = [
    (enFlag "udev" (libgudev != null) null)
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
      x86_64-linux;
  };
}
