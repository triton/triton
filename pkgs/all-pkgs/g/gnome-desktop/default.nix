{ stdenv
, fetchurl
, gettext
, lib
, meson
, ninja

, atk
, gdk-pixbuf
, glib
, gobject-introspection
, gsettings-desktop-schemas
, gtk
, iso-codes
, libseccomp
, libx11
, libxext
, libxkbfile
, libxml2
, libxrandr
, pango
, python
, systemd_lib
, wayland
, xkeyboard-config
, xorgproto

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt
    optionals;

  sources = {
    "3.31" = {
      version = "3.31.1";
      sha256 = "67f17d329b06b58652752c13b69a34e63c3c68529e7a06b043b7db9c22c7d188";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gnome-desktop-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-desktop/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
  ];

  buildInputs = [
    atk
    gdk-pixbuf
    glib
    gobject-introspection
    gsettings-desktop-schemas
    gtk
    iso-codes
    libseccomp
    libx11
    libxext
    libxkbfile
    libxml2
    libxrandr
    pango
    systemd_lib
    xkeyboard-config
    xorgproto
  ];

  mesonFlags = [
    "-Ddate_in_gnome_version=false"
    "-Ddesktop_docs=false"
    "-Ddebug_tools=false"
    "-Dudev=enabled"
  ];

  postPatch = /* FIXME: find way to support bwrap */ ''
    sed -i meson.build \
      -e '/HAVE_BWRAP/d'
  '' + /* Fix hardcoded bubblewrap paths */ ''
    sed -i libgnome-desktop/gnome-desktop-thumbnail-script.c \
      -e '/\/lib64/d' \
      -e "/--ro-bind/ s,/usr,${gdk-pixbuf}," \
      -e "/--symlink/ s,usr/bin,${gdk-pixbuf}/bin,g" \
      -e "/--ro-bind/ s,/lib,${gdk-pixbuf}/lib," \
      -e '/usr\/sbin/d'
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/gnome-desktop/${channel}/"
          + "${name}.sha256sum";
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Libraries for the gnome desktop that are not part of the UI";
    homepage = https://git.gnome.org/browse/gnome-desktop;
    license = with licenses; [
      #fdl11
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
