{ stdenv
, fetchurl
, gettext
, intltool
, itstool
, makeWrapper
, perl
, perlPackages

, adwaita-icon-theme
, atk
, cairo
, dconf
, djvulibre
, gdk-pixbuf
, glib
, gnome-desktop
, gobject-introspection
, gsettings-desktop-schemas
, gst-plugins-base
, gst-plugins-good
, gstreamer
, gtk
, gvfs
, libgxps
, libsecret
, libspectre
, libtiff
, libxml2
, nautilus
, pango
, poppler
, shared-mime-info
, zlib

, python

, recentListSize ? null # 5 is not enough, allow passing a different number

, channel
}:

let
  inherit (builtins)
    toString;
  inherit (stdenv.lib)
    boolEn
    boolWt
    optionals
    optionalString;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "evince-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/evince/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
    itstool
    makeWrapper
    perl
    perlPackages.XMLParser
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    cairo
    dconf
    djvulibre
    gdk-pixbuf
    glib
    gnome-desktop
    gobject-introspection
    gsettings-desktop-schemas
    gst-plugins-base
    gst-plugins-good
    gstreamer
    gtk
    gvfs
    libgxps
    libsecret
    libspectre
    libtiff
    libxml2
    nautilus
    pango
    poppler
    zlib
  ] ++ optionals doCheck [
    python
  ];

  preConfigure =
    optionalString doCheck ''
      for file in test/*.py ; do
        echo "patching $file"
        sed -i "$file" \
          -e '1s,/usr,${python},'
      done
    '' +
    optionalString (recentListSize != null) ''
      sed -i  shell/ev-open-recent-action.c \
        -e 's/\(gtk_recent_chooser_set_limit .*\)5)/\1${toString recentListSize})/'
      sed -i  shell/ev-window.c \
        -e 's/\(if (++n_items == \)5\(.*\)/\1${toString recentListSize}\2/'
    '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-cxx-warnings"
    "--disable-iso-cxx"
    "--enable-nls"
    "--enable-scheams-compile"
    "--${boolEn (glib != null)}-dbus"
    "--enable-libgnome-desktop"
    "--${boolEn (gnome-desktop != null)}-libgnome-desktop"
    "--${boolEn (
      gstreamer != null
      && gst-plugins-base != null
      && gst-plugins-good != null)}-multimedia"
    "--disable-debug"
    "--${boolEn (
      nautilus != null
      && gtk != null
      && glib != null)}-nautilus"
    "--enable-viewer"
    "--enable-thumbnailer"
    "--${boolEn (
      gtk != null
      && glib != null)}-previewer"
    "--${boolEn (
      gtk != null
      && glib != null)}-browser-plugin"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolEn (
      poppler != null
      && libxml2 != null)}-pdf"
    "--${boolEn (libspectre != null)}-ps"
    "--${boolEn (
      libtiff != null
      && zlib != null)}-tiff"
    "--enable-djvu"
    "--${boolEn (djvulibre != null)}-djvu"
    # TODO: dvi support (kpathsea)
    "--disable-dvi"
    "--enable-t1lib"
    "--enable-comics"
    "--${boolEn (libgxps != null)}-xps"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--with-platform=gnome"
    "--${boolWt (gtk != null)}-gtk-unix-print"
    "--${boolWt (libsecret != null)}-keyring"
  ];

  preFixup = ''
    wrapProgram $out/bin/evince \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'PATH' : "${gvfs}/bin" \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share"

    wrapProgram $out/bin/evince-previewer \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --prefix 'PATH' : "${gvfs}/bin" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share"

    wrapProgram $out/bin/evince-thumbnailer \
      --prefix 'PATH' : "${gvfs}/bin" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share"
  '';

  doCheck = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/evince/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "Simple document viewer for GNOME";
    homepage = http://www.gnome.org/projects/evince/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
