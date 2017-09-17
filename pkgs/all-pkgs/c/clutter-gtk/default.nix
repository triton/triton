{ stdenv
, fetchurl
, gettext
, lib
, meson
, ninja

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
  inherit (lib)
    boolEn;

  sources = {
    "1.8" = {
      version = "1.8.4";
      sha256 = "521493ec038973c77edcb8bc5eac23eed41645117894aaee7300b2487cb42b06";
    };
  };
  source = sources."${channel}";
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
    meson
    ninja
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

  mesonFlags = [
    "-Denable_docs=false"
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

  meta = with lib; {
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
