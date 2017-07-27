{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl
, gettext
, gtk-doc
, intltool
, lib
, makeWrapper

, adwaita-icon-theme
, atk
, dbus-glib
, dconf
, exempi
, gdk-pixbuf
, glib
, gnome-autoar
, gnome-desktop
, gobject-introspection
, gsettings-desktop-schemas
, gtk
, gvfs
, libexif
, libnotify
, librsvg
, libunique
, libx11
, libxml2
, pango
, shared-mime-info
, tracker

, channel
}:

let
  inherit (lib)
    boolEn
    optionals
    versionOlder;

  sources = {
    "3.24" = {
      version = "3.24.2";
      sha256 = "e5b0036f6fbfaf2e9d9ddbac98e19a43f3d8b626f73d1680e979fa312845cc60";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "nautilus-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/nautilus/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
    gtk-doc  # autoreconf
    intltool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    dbus-glib
    dconf
    exempi
    gdk-pixbuf
    glib
    gnome-autoar
    gnome-desktop
    gobject-introspection
    gsettings-desktop-schemas
    gtk
    gvfs
    libexif
    libnotify
    librsvg
    libunique
    libxml2
    pango
    tracker
    libx11
  ];

  # FIXME
  # patches = optionals (versionOlder channel "3.22") [
  #   (fetchTritonPatch {
  #     rev = "734f89c9d36781e3f50f30dc9aa33d071136dbd0";
  #     file = "nautilus/extension_dir.patch";
  #     sha256 = "ebd28b1f94106562574bb43884565761a34f233bcefa0ab516bf82e7691ee764";
  #   })
  # ];

  preAutoreconf = ''
    mkdir m4 && gtkdocize --copy
  '';

  postAutoreconf = ''
    sed -i configure \
      -e '/GTK_DOC_CHECK/d' \
      -e 's/DISABLE_DEPRECATED_CFLAGS=.*/DISABLE_DEPRECATED_CFLAGS=/'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-schemas-compile"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-profiling"
    "--enable-nst-extension"
    "--${boolEn (libexif != null)}-libexif"
    "--enable-xmp"
    "--disable-selinux"
    "--enable-desktop"
    "--enable-packagekit"
    "--enable-more-warnings"
    "--${boolEn (tracker != null)}-tracker"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-update-mimedb"
  ];

  preFixup = ''
    wrapProgram $out/bin/nautilus \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'PATH' : "${gvfs}/bin" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/nautilus/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A file manager for the GNOME desktop";
    homepage = https://wiki.gnome.org/Apps/Nautilus;
    license = with licenses; [
      fdl11
      gpl2Plus
      lgpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
