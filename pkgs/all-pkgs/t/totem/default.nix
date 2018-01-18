{ stdenv
, fetchurl
, gettext
, intltool
, itstool
, lib
, makeWrapper
, meson
, ninja

, adwaita-icon-theme
, atk
, cairo
, clutter
, clutter-gst
, clutter-gtk
#, cogl
, dbus-glib
, dconf
, gdk-pixbuf
, glib
, gnome-desktop
, gobject-introspection
, grilo
, grilo-plugins
, gsettings-desktop-schemas
, gst-libav
, gst-plugins-bad
, gst-plugins-base
, gst-plugins-good
, gst-plugins-ugly
, gstreamer
, gtk
, libpeas
, libx11
, libxml2
, lirc
, nautilus
, pango
#, python3Packages
, shared-mime-info
, totem-pl-parser
, tracker
#, vala
, xextproto
, xproto
#, zeitgeist

, channel
}:

let
  inherit (lib)
    makeSearchPath;

  sources = {
    "3.26" = {
      version = "3.26.0";
      sha256 = "e32fb9a68097045e75c87ad1b8177f5c01aea2a13dcb3b2e71a0f9570fe9ee13";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "totem-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/totem/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
    itstool
    makeWrapper
    meson
    ninja
    #vala
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    cairo
    clutter
    clutter-gst
    clutter-gtk
    #cogl
    dbus-glib
    dconf
    gdk-pixbuf
    glib
    gnome-desktop
    gobject-introspection
    grilo
    grilo-plugins
    gsettings-desktop-schemas
    gst-plugins-base
    gstreamer
    gtk
    libpeas
    libx11
    libxml2
    lirc
    nautilus
    pango
    #python3Packages.pygobject
    #python3Packages.pylint
    #python3Packages.python
    totem-pl-parser
    tracker
    xextproto
    xproto
    #zeitgeist
  ];

  GST_PLUGIN_PATH = makeSearchPath "lib/gstreamer-1.0" [
    gst-libav
    gst-plugins-bad
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
    gstreamer
  ];

  postPatch = /* Post install is already handled by setup-hooks */ ''
    sed -i meson.build \
      -e '/meson_post_install.py/d' \
      -e '/meson_compile_python.py/d'
  '';

  preConfigure = ''
    mesonFlagsArray+=("-Dwith-nautilusdir=$out/lib/nautilus/extensions-3.0/")
  '';

  mesonFlags = [
    "-Denable-easy-codec-installation=yes"
    "-Denable-python=no"
    "-Denable-vala=no"
    "-Dwith-plugins=all"
    "-Denable-nautilus=yes"
    "-Denable-gtk-doc=false"
    "-Denable-introspection=yes"
  ];

  preFixup = ''
    wrapProgram $out/bin/totem \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'GRL_PLUGIN_PATH' : "$GRL_PLUGIN_PATH" \
      --prefix 'GST_PLUGIN_PATH' : "$GST_PLUGIN_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --prefix 'XDG_DATA_DIRS' : "$out/share"

    wrapProgram $out/bin/totem-video-thumbnailer \
      --prefix 'GST_PLUGIN_PATH' : "$GST_PLUGIN_PATH" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share"
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/totem/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Media player for GNOME";
    homepage = https://wiki.gnome.org/Apps/Videos;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
