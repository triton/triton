{ stdenv
, fetchurl
, gettext
, lib
, libxml2
, makeWrapper
, meson
, ninja

, adwaita-icon-theme
, atk
, dconf
, gdk-pixbuf
, glib
, gobject-introspection
, gtk
, libcanberra
, libnotify
, pango
, shared-mime-info
, systemd_lib

, channel
}:

let
  sources = {
    "3.31" = {
      version = "3.31.1";
      sha256 = "9d9a16dc5ae50e141b294daba2f5b2cb34eaf9b98568f9fb7ecb72d8a18d80f7";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gnome-bluetooth-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-bluetooth/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    libxml2
    makeWrapper
    meson
    ninja
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
    pango
    systemd_lib
  ];

  postPatch = ''
    grep -q 'meson_post_install.py' meson.build
    sed -i meson.build \
      -e '/add_install_script/,+4 d'
  '';

  mesonFlags = [
    "-Dicon_update=false"
  ];

  preFixup = ''
    wrapProgram $out/bin/bluetooth-sendto \
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
      fullOpts = {
        sha256Urls =
          map (u: lib.replaceStrings ["tar.xz"] ["sha256sum"] u) src.urls;
      };
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
