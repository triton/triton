{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, itstool
, lib
, makeWrapper
, meson
, ninja
, python3

, atk
, bubblewrap
, dbus-glib
, exempi
, gdk-pixbuf
, glib
, gnome-autoar
, gnome-desktop
, gobject-introspection
, gsettings-desktop-schemas
, gtk
, gvfs
, libexif
, libnotify
, librsvg
, libunique
, libx11
, libxml2
, pango
, shared-mime-info
, tracker

, channel
}:

let
  inherit (lib)
    boolTf
    optionals
    versionOlder;

  sources = {
    "3.26" = {
      version = "3.26.2";
      sha256 = "79c99404c665ea76b3db86f261fbd28a62b54c51429b05c3314462c9de2614b4";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "nautilus-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/nautilus/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    itstool
    makeWrapper
    meson
    ninja
    python3
  ];

  buildInputs = [
    atk
    dbus-glib
    exempi
    gdk-pixbuf
    glib
    gnome-autoar
    gnome-desktop
    gobject-introspection
    gsettings-desktop-schemas
    gtk
    gvfs
    libexif
    libnotify
    librsvg
    libunique
    libxml2
    pango
    tracker
    libx11
  ];

  setupHook = ./setup-hook.sh;

  patches = [
    # Allow loading extensions outside of nautilus's prefix
    (fetchTritonPatch {
      rev = "d16377bd86600e01062db38ce0ba71e0651b6fbd";
      file = "n/nautilus/extension_dir.patch";
      sha256 = "b61effd0d234cbf0cfcfa024402fd952307d3d4461056e645d2d17b73563a4fe";
    })
  ];

  postPatch = /* Disable post-install hook, already handled by setup-hooks */ ''
    sed -i meson.build \
      -e '/postinstall.py/d'
  '';

  mesonFlags = [
    "-Denable-profiling=false"
    "-Denable-nst-extension=true"
    "-Denable-exif=${boolTf (libexif != null)}"
    "-Denable-xmp=${boolTf (exempi != null)}"
    "-Denable-selinux=false"  # FIXME
    "-Denable-desktop=true"
    "-Denable-packagekit=false"
    "-Denable-tracker=${boolTf (tracker != null)}"  # FIXME: remove next release
    "-Denable-gtk-doc=false"
  ];

  passthru = {
    inherit (source) version;

    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/nautilus/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A file manager for the GNOME desktop";
    homepage = https://wiki.gnome.org/Apps/Nautilus;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
