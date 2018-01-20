{ stdenv
, fetchurl
, lib

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
  inherit (lib)
    boolEn
    optionals;

  channel = "3.0";
  version = "${channel}.24";
in
stdenv.mkDerivation rec {
  name = "clutter-gst-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/clutter-gst/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "e9f1c87d8f4c47062e952fb8008704f8942cf2d6f290688f3f7d13e83578cc6c";
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
    "--${boolEn (libgudev != null)}-udev"
    "--enable-gl-texture-upload"
    "--disable-maintainer-flags"
    "--disable-debug"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolEn (gobject-introspection != null)}-introspection"
  ];

  postBuild = "rm -rvf $out/share/gtk-doc";

  buildParallel = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/clutter-gst/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
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
