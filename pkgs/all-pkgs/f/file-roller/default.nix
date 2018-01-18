{ stdenv
, fetchurl
, gettext
, intltool
, itstool
, lib
, makeWrapper

, adwaita-icon-theme
, cairo
, dconf
, file
, gdk-pixbuf
, glib
, gtk
, json-glib
, libarchive
, libnotify
, libxml2
, nautilus

, channel
}:

let
  inherit (lib)
    boolEn;

  sources = {
    "3.26" = {
      version = "3.26.2";
      sha256 = "3e677b8e1c2f19aead69cf4fc419a19fc3373aaf5d7bf558b4f077f10bbba8a5";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "file-roller-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/file-roller/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
    itstool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    dconf
    file
    gdk-pixbuf
    glib
    gtk
    json-glib
    libarchive
    libnotify
    libxml2
    nautilus
  ];

  configureFlags = [
    "--disable-schemas-compile"
    "--disable-debug"
    "--disable-run-in-place"
    "--enable-nautilus-actions"
    #"--enable-packagekit"
    "--${boolEn (libnotify != null)}-notification"
    #"--enable-magic"
    "--${boolEn (libarchive != null)}-libarchive"
    "--enable-nls"
    "--disable-deprecated"
  ];

  preInstall = ''
    installFlagsArray+=(
      "nautilus_extensiondir=$out/lib/nautilus/extensions-3.0"
    )
  '';

  preFixup = ''
    wrapProgram "$out/bin/file-roller" \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix XDG_DATA_DIRS : "$out/share" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS"
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/file-roller/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Archive manager for the GNOME desktop environment";
    homepage = https://wiki.gnome.org/Apps/FileRoller;
    licenses = licenses.free;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
