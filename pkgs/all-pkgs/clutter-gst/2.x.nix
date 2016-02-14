{ stdenv
, fetchurl

, atk
, clutter
, cogl
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
  versionMajor = "2.0";
  versionMinor = "16";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/clutter-gst/${versionMajor}/${name}.tar.xz";
    sha256 = "0f90fkywwn9ww6a8kfjiy4xx65b09yaj771jlsmj2w4khr0zhi59";
  };

  configureFlags = [
    "--disable-maintainer-flags"
    "--disable-debug"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
  ];

  buildInputs = [
    atk
    clutter
    cogl
    glib
    gobject-introspection
    gstreamer
    gst-plugins-base
    gtk3
    json-glib
    pango
  ];

  postBuild = "rm -rf $out/share/gtk-doc";

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "GStreamer bindings for clutter";
    homepage = http://www.clutter-project.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms =  with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
