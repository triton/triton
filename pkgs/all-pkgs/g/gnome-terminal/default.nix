{ stdenv
, desktop_file_utils
, fetchurl
, gettext
, gnome_doc_utils
, intltool
, itstool
, lib
, libxml2
, makeWrapper
, util-linux_lib
, which

, adwaita-icon-theme
, dconf
, gdk-pixbuf
, glib
, gsettings-desktop-schemas
, gtk
, libx11
, nautilus
, shared-mime-info
, vala
, vte

, channel
}:

let
  sources = {
    "3.26" = {
      version = "3.26.2";
      sha256 = "3a9ba414a814569476515275ad303d8056f296b2669234447712559aa97005b0";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gnome-terminal-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-terminal/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    desktop_file_utils
    gettext
    gnome_doc_utils
    intltool
    itstool
    libxml2
    makeWrapper
    util-linux_lib
    vala
    which
  ];

  buildInputs = [
    adwaita-icon-theme
    dconf
    gdk-pixbuf
    glib
    gsettings-desktop-schemas
    gtk
    nautilus
    vte
    libx11
  ];

  postPatch = /* Remove pointless "Copy as HTML" context option */ ''
    sed -i src/terminal.xml \
      -e '/CopyHTML"/d'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-gterminal"
    "--disable-schemas-compile"
    "--disable-migration"
    "--disable-search-provider"
    "--disable-distro-packaging"
    "--disable-debug"
    "--with-gtk=3.0"
    "--with-nautilus-extension"
    #"--with-nautilus-dir=PATH"
  ];

  preFixup = ''
    wrapProgram "$out/libexec/gnome-terminal-server" \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
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
      sha256Url = "https://download.gnome.org/sources/gnome-terminal/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "The Gnome Terminal";
    homepage = https://wiki.gnome.org/Apps/Terminal/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
