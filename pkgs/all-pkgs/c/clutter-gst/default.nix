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
  version = "${channel}.27";
in
stdenv.mkDerivation rec {
  name = "clutter-gst-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/clutter-gst/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "fe69bd6c659d24ab30da3f091eb91cd1970026d431179b0724f13791e8ad9f9d";
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
  installParallel = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = map (n: (lib.replaceStrings ["tar.xz"] ["sha256sum"] n)) src.urls;
      };
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
