{ stdenv
, fetchurl
, pkgconfig
, intltool
, itstool

, avahi
, glib
, gmime
, gnome-online-accounts
, gom
, grilo
, gssdp
, gupnp
, gupnp-av
, json-glib
, libarchive
, libgdata
, libmediaart
, liboauth
, libsoup
, libxml2
, lua5
, rest
, sqlite
, totem-pl-parser
, tracker
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "grilo-plugins-${version}";
  versionMajor = "0.2";
  versionMinor = "17";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/grilo-plugins/${versionMajor}/${name}.tar.xz";
    sha256 = "109pf4sz320jiqs1nzszpj2flkwrgwfsm64kza24mxnxih4njxik";
  };

  nativeBuildInputs = [
    intltool
    itstool
  ];

  buildInputs = [
    avahi
    glib
    gmime
    gnome-online-accounts
    gom
    grilo
    json-glib
    libarchive
    libgdata
    libmediaart
    liboauth
    libsoup
    libxml2
    lua5
    sqlite
    totem-pl-parser
    tracker
  ];

  configureFlags = [
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-maintainer-mode"
    "--disable-uninstalled"
    "--disable-debug"
    (enFlag "goa" (gnome-online-accounts != null) null)
    "--disable-gcov"
    "--enable-filesystem"
    "--enable-optical-media"
    "--enable-jamendo"
    "--enable-youtube"
    "--enable-flickr"
    "--enable-podcasts"
    "--enable-bookmarks"
    "--enable-shoutcast"
    "--enable-magnatune"
    "--enable-lua-factory"
    "--enable-metadata-store"
    "--enable-vimeo"
    "--enable-gravatar"
    "--enable-tracker"
    "--enable-raitv"
    "--enable-localmetadata"
    "--enable-dleyna"
    # TODO: requires libmapsharing support
    "--disable-dmap"
    "--enable-thetvdb"
    "--enable-tmdb"
    "--enable-freebox"
    "--enable-opensubtitles"
    "--enable-nls"
  ];

  installFlags = [
    "GRL_PLUGINS_DIR=$(out)/lib/grilo-0.2"
  ];

  meta = with stdenv.lib; {
    description = "A collection of plugins for the Grilo framework";
    homepage = https://wiki.gnome.org/action/show/Projects/Grilo;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
