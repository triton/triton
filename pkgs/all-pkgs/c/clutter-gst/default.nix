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
  version = "${channel}.26";
in
stdenv.mkDerivation rec {
  name = "clutter-gst-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/clutter-gst/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "d8618a6d9accec0f2a8574c5e1220051f8505fb82b20336c26bdbd482aa6cb3a";
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
