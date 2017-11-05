{ stdenv
, autoconf
, automake
, fetchurl
, gnome-common
, gtk-doc
, intltool
, itstool
, lib
, libtool
, makeWrapper

, adwaita-icon-theme
, atk
, dconf
, gdk-pixbuf
, glib
, gobject-introspection
, gtk
, libcanberra
, libnotify
, libxml2
, pango
, shared-mime-info
, systemd_lib

, channel
}:

let
  inherit (lib)
    boolEn
    replaceStrings;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "gnome-bluetooth-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-bluetooth/${channel}/"
      + "${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    intltool
    itstool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    dconf
    gdk-pixbuf
    glib
    gobject-introspection
    gtk
    libcanberra
    libnotify
    libxml2
    pango
    systemd_lib
  ];

  postPatch =
    /* Regenerate gdbus-codegen files to allow using any glib version
    	 https://bugzilla.gnome.org/show_bug.cgi?id=758096 */ ''
    	rm -v lib/bluetooth-client-glue.{c,h}
    '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-schemas-compile"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-desktop-update"
    "--disable-icon-update"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-debug"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-documentation"
  ];

  postConfigure = /* https://bugzilla.gnome.org/show_bug.cgi?id=655517 */ ''
    sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
  '';

  preFixup = ''
    wrapProgram $out/bin/bluetooth-sendto \
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
      sha256Url = "https://download.gnome.org/sources/gnome-bluetooth/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Bluetooth graphical utilities integrated with GNOME";
    homepage = https://wiki.gnome.org/Projects/GnomeBluetooth;
    license = with licenses; [
      #fdl11
      gpl2Plus
      lgpl21Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
