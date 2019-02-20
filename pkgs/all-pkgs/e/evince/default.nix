{ stdenv
, fetchFromGitLab
, fetchurl
, gettext
, itstool
, lib
, makeWrapper
, meson
, ninja

, adwaita-icon-theme
, appstream-glib  # ITS rules
, atk
, cairo
, dconf
, dbus
, djvulibre
, gdk-pixbuf
, glib
, gnome-desktop
, gobject-introspection
, gsettings-desktop-schemas
#, gspell
, gst-plugins-base
, gst-plugins-good
, gstreamer
, gtk
, gvfs
, libarchive
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

# 5 is not enough, allow passing a different number
, recentListSize ? null

, channel
}:

let
  inherit (builtins)
    toString;
  inherit (lib)
    boolEn
    boolWt
    optionals
    optionalString;

  sources = {
    "3.32" = {
      #version = "3.32.x";
      version = "2019-02-16";
      #sha256 = "ff279568bf1122b850f4ac1ed1839f952805358b4babb5602ecc3a52514bb61b";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "evince-${source.version}";

  #src = fetchurl {
  #  url = "mirror://gnome/sources/evince/${channel}/${name}.tar.xz";
  #  hashOutput = false;
  #  inherit (source) sha256;
  #};

  src = fetchFromGitLab {
    version = 6;
    host = "https://gitlab.gnome.org";
    owner = "GNOME";
    repo = "evince";
    rev = "f627796fb273b0e449f0f3fca7664e7cb1a84177";
    sha256 = "3e3fd09782f3ee5e2409a2d21aefd8049efe1c00ad3bf245af6e0b419a29f74e";
  };

  nativeBuildInputs = [
    gettext
    itstool
    makeWrapper
    meson
    ninja
  ];

  buildInputs = [
    adwaita-icon-theme
    appstream-glib
    atk
    cairo
    dbus
    dconf
    djvulibre
    gdk-pixbuf
    glib
    gnome-desktop
    gobject-introspection
    gsettings-desktop-schemas
    #gspell
    gst-plugins-base
    gst-plugins-good
    gstreamer
    gtk
    gvfs
    libarchive
    libgxps
    libsecret
    libspectre
    libtiff
    libxml2
    nautilus
    pango
    poppler
    zlib
  ];

  preConfigure = /* Fix hardcoded install path */ ''
    grep -q 'libnautilus_extension_dep.get_pkgconfig_variable' meson.build
    sed -i meson.build \
      -e "s,nautilus_extension_dir.*$,nautilus_extension_dir = '$out/lib/nautilus/extensions-3.0',"
  '' + /* Handled by setup-hooks */ ''
    grep -q 'meson_post_install.py' meson.build
    sed -i meson.build \
      -e '/add_install_script/,+3 d'
  '' + /* Remove hardcoded reference to the build directory */ ''
    grep -q '@filename@' libdocument/ev-document-type-builtins.h.template
    grep -q '@filename@' libview/ev-view-type-builtins.h.template
    sed -i libdocument/ev-document-type-builtins.h.template \
      -i libview/ev-view-type-builtins.h.template \
      -e 's,"@filename@",,'
  '' + optionalString (recentListSize != null) ''
    sed -i  shell/ev-open-recent-action.c \
      -e 's/\(gtk_recent_chooser_set_limit .*\)5)/\1${toString recentListSize})/'
    sed -i  shell/ev-window.c \
      -e 's/\(if (++n_items == \)5\(.*\)/\1${toString recentListSize}\2/'
  '';

  mesonFlags = [
    "-Dcomics=enabled"
    "-Ddjvu=enabled"
    "-Ddvi=disabled"  # FIXME: kpathsea
    "-Dpdf=enabled"
    "-Dps=enabled"
    "-Dtiff=enabled"
    "-Dxps=enabled"
    "-Dgtk_doc=false"
    "-Dkeyring=enabled"
    "-Dgtk_unix_print=enabled"
    "-Dgspell=disabled"  # FIXME
    "-Dt1lib=enabled"
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

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Urls = map (n: (lib.replaceStrings ["tar.xz"] ["sha256sum"] n)) src.urls;
      };
      failEarly = true;
    };
  };

  meta = with lib; {
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
