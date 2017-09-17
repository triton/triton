{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, lib
, makeWrapper
, meson
, ninja
, python3

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
    boolTf
    optionals
    versionOlder;

  sources = {
    "3.26" = {
      version = "3.26.0";
      sha256 = "a02b30ef9033f6f92fbc5e29abaceeb58ce6a600ed9fa5a4697ba82901d07924";
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
    gettext
    makeWrapper
    meson
    ninja
    python3
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

  postPatch = /* Disable post-install hook, already handled by setup-hooks */ ''
    sed -i meson.build \
      -e '/postinstall.py/d'
  '' + /* FIXME: i18n.merge_file in meson is failing with permission denied */ ''
    sed -i data/meson.build \
      -e '/org.gnome.Nautilus.desktop/ N; s/install: true/install: false/'
  '';

  mesonFlags = [
    "-Denable-profiling=false"
    "-Denable-nst-extension=true"
    "-Denable-exif=${boolTf (libexif != null)}"
    "-Denable-xmp=${boolTf (exempi != null)}"
    "-Denable-selinux=false"  # FIXME
    "-Denable-desktop=true"
    "-Denable-packagekit=false"
    "-Denable-tracker=${boolTf (tracker != null)}"  # FIXME: remove next release
    "-Denable-gtk-doc=false"
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
