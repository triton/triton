{ stdenv
, fetchurl
, gettext
, intltool
, lib
, makeWrapper
# , meson
# , ninja

, adwaita-icon-theme
, appstream-glib
, dconf
, gdk-pixbuf
, glib
, gtk
, libxml2
, shared-mime-info

, channel
}:

let
  inherit (lib)
    boolEn;

  sources = {
    "3.26" = {
      version = "3.26.2";
      sha256 = "28b453fe49c49d7dfaf07c85c01d7495913f93ab64a0b223c117eb17d1cb8ad1";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "dconf-editor-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/dconf-editor/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
    # meson
    # ninja
  ];

  buildInputs = [
    adwaita-icon-theme
    appstream-glib
    dconf
    gdk-pixbuf
    glib
    gtk
    libxml2
  ];

  # postPatch = ''
  #   sed -i meson.build \
  #     -e '/meson_post_install.py/d'
  # '';

  configureFlags = [
    "--enable-schemas-compile"
    "--${boolEn (appstream-glib != null)}-appstream-util"
    "--enable-nls"
  ];

  preFixup = ''
    wrapProgram "$out/bin/dconf-editor" \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
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
      sha256Url = "https://download.gnome.org/sources/dconf-editor/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Graphical tool for editing the dconf configuration database";
    homepage = https://git.gnome.org/browse/dconf-editor;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
