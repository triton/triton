{ stdenv
, appstream-glib
, fetchurl
, gettext
, lib
, makeWrapper
, meson
, ninja

, adwaita-icon-theme
, dconf
, gdk-pixbuf
, glib
, gobject-introspection
, gsettings-desktop-schemas
, gtk
, libcanberra
, libx11
, libxext
, libxml2
, shared-mime-info

, channel
}:

let
  sources = {
    "3.26" = {
      version = "3.26.0";
      sha256 = "1bbc11595d3822f4b92319cdf9ba49dd00f5471b6046c590847dc424a874c8bb";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gnome-screenshot-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-screenshot/${channel}/"
      + "${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    appstream-glib
    gettext
    makeWrapper
    meson
    ninja
  ];

  buildInputs = [
    adwaita-icon-theme
    dconf
    gdk-pixbuf
    glib
    gobject-introspection
    gsettings-desktop-schemas
    gtk
    libcanberra
    libx11
    libxext
    libxml2
  ];

  postPatch = /* Disable post-install hook, already handled by setup-hooks */ ''
    sed -i meson.build \
      -e '/postinstall.py/d'
  '';

  preFixup = ''
    wrapProgram $out/bin/gnome-screenshot \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  doCheck = true;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gnome-screenshot/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Utility used in the GNOME desktop environment for screenshots";
    homepage = http://en.wikipedia.org/wiki/GNOME_Screenshot;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
