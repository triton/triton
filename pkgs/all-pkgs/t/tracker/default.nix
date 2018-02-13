{ stdenv
, fetchurl
, gettext
, intltool
, itstool
, lib
, makeWrapper
, python3

, adwaita-icon-theme
, bash
, bzip2
, c-ares
, dconf
#, evolution
, evolution-data-server
, exempi
, file
, ffmpeg
, flac
, gdk-pixbuf
, giflib
, glib
, gnome-themes-standard
, gobject-introspection
, gsettings-desktop-schemas
, gst-libav
, gst-plugins-base
, gstreamer
, gtk
, icu
, json-glib
, libcue
, libexif
, libgee
, libgsf
, libgxps
, libjpeg
, libmediaart
, libnotify
, libogg
, libosinfo
, libpng
, librsvg
, libseccomp
, libsoup
, libtiff
, libvorbis
, libxml2
, libxslt
, networkmanager
, poppler
, sqlite
, systemd_lib
, taglib
, totem-pl-parser
, upower
, util-linux_lib
, vala
, zlib

, channel
}:

let
  inherit (lib)
    boolEn;

  sources = {
    "2.0" = {
      version = "2.0.3";
      sha256 = "5a2fb274c128ec67a920944937b5147ceaf5db16fef6691ea22c4cb841e20580";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "tracker-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/tracker/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  propagatedUserEnvPkgs = [
    gnome-themes-standard
  ];

  nativeBuildInputs = [
    gettext
    intltool
    itstool
    libxslt
    makeWrapper
    python3
    vala
  ];

  buildInputs = [
    adwaita-icon-theme
    bzip2
    c-ares
    #cairo
    dconf
    #enca
    #evolution
    evolution-data-server
    exempi
    file
    #firefox
    ffmpeg
    flac
    gdk-pixbuf
    giflib
    glib
    gobject-introspection
    gsettings-desktop-schemas
    libgee
    totem-pl-parser
    gst-libav
    gst-plugins-base
    gstreamer
    gtk
    #gupnp-dlna
    icu
    json-glib
    libcue
    libexif
    #libgrss
    libgsf
    libgxps
    #libiptcdata
    libjpeg
    libmediaart
    libnotify
    libogg
    libosinfo
    libpng
    librsvg
    libseccomp
    libsoup
    libtiff
    libvorbis
    libxml2
    networkmanager
    #pango
    poppler
    sqlite
    systemd_lib
    taglib
    #thunderbird
    upower
    util-linux_lib
    zlib
  ];

  postPatch = ''
    patchShebangs utils/g-ir-merge/g-ir-merge
  '';

  preConfigure = ''
    sed -i src/libtracker-sparql/Makefile.in \
      -e "s,--shared-library=libtracker-sparql,--shared-library=$out/lib/libtracker-sparql,"
  '';

  configureFlags = [
    "--enable-schemas-compile"
    "--disable-installed-tests"
    "--disable-always-build-tests"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--enable-nls"
    "--disable-gcov"
    "--disable-minimal"
    "--disable-functional-tests"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-maemo"
    "--enable-journal"
    # TODO: libstemmer support
    "--disable-libstemmer"
    "--enable-tracker-fts"
    "--disable-unit-tests"
    "--${boolEn (upower != null)}-upower"
    "--disable-hal"
    "--${boolEn (networkmanager != null)}-network-manager"
    "--${boolEn (libmediaart != null)}-libmediaart"
    "--${boolEn (libexif != null)}-libexif"
    # TODO: libiptcdata support
    "--disable-libiptcdata"
    "--${boolEn (exempi != null)}-exempi"
    "--disable-meegotouch"
    "--enable-miner-fs"
    "--enable-extract"
    "--enable-tracker-writeback"
    "--disable-miner-apps"
    "--disable-miner-user-guides"
    # TODO: miner-rss support
    "--disable-miner-rss"
    # evolution currently requires webkit-2.4
    "--disable-miner-evolution"
    # TODO: thunderbird support
    "--disable-miner-thunderbird"
    # TODO: firefox support
    "--disable-miner-firefox"
    # TODO: nautilus support
    "--disable-nautilus-extension"
    "--${boolEn (taglib != null)}-taglib"
    "--enable-tracker-needle"
    "--enable-tracker-preferences"
    "--disable-enca"  # ICU is used instead
    "--enable-icu-charset-detection"
    "--${boolEn (libxml2 != null)}-libxml2"
    "--enable-generic-media-extractor=libav"
    "--enable-unzip-ps-gz-files"
    "--${boolEn (poppler != null)}-poppler"
    "--${boolEn (libgxps != null)}-libgxps"
    "--${boolEn (libgsf != null)}-libgsf"
    "--${boolEn (libosinfo != null)}-libosinfo"
    "--${boolEn (giflib != null)}-libgif"
    "--${boolEn (libjpeg != null)}-libjpeg"
    "--${boolEn (libtiff != null)}-libtiff"
    "--${boolEn (libpng != null)}-libpng"
    "--${boolEn (libvorbis != null)}-libvorbis"
    "--${boolEn (flac != null)}-libflac"
    "--${boolEn (libcue != null)}-libcue"
    "--enable-abiword"
    "--enable-dvi"
    "--enable-mp3"
    "--enable-ps"
    "--enable-text"
    "--enable-icon"
    "--enable-playlist"
    "--enable-guarantee-metadata"
    "--enable-artwork"
    "--with-compile-warnings"
    #"--with-bash-completion-dir="
    #"--with-session-bus-services-dir"
    "--with-unicode-support=libicu"
    #"--with-evolution-plugin-dir"
    #"--with-thunderbird-plugin-dir"
    #"--with-firefox-plugin-dir"
    #"--with-nautilus-extensions-dir"
    # TODO: gstreamer support
    "--with-gstreamer-backend=discoverer"
  ];

  preFixup = ''
    wrapProgram $out/bin/tracker \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share"

    wrapProgram $out/libexec/tracker-store \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share"
  '';

  # FIXME
  buildDirCheck = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/tracker/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "User information store, search tool and indexer";
    homepage = https://wiki.gnome.org/Projects/Tracker;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
