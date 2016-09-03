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

, channel
}:

let
  inherit (stdenv.lib)
    enFlag
    optionals
    strings;

  is3x = strings.substring 0 1 channel == "3";

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "clutter-gst-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/clutter-gst/${channel}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/clutter-gst/${channel}/"
      + "${name}.sha256sum";
    inherit (source) sha256;
  };

  buildInputs = [
    atk
    clutter
    cogl
    glib
    gobject-introspection
    gst-plugins-base
    gstreamer
    gtk3
    json-glib
    pango
  ] ++ optionals is3x [
    gdk-pixbuf
    libgudev
  ];

  configureFlags = [
    #"--help"
    "--disable-maintainer-flags"
    "--disable-debug"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
  ] ++ optionals is3x [
    (enFlag "udev" (libgudev != null) null)
    "--enable-gl-texture-upload"
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
