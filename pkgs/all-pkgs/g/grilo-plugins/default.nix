{ stdenv
, gperf
, fetchurl
, pkgconfig
, intltool
, itstool
, lib

, avahi
, glib
, gmime
#, gnome-online-accounts
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
, lua
, rest
, sqlite
, totem-pl-parser
, tracker
}:

let
  channel = "0.3";
  version = "${channel}.5";
in
stdenv.mkDerivation rec {
  name = "grilo-plugins-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/grilo-plugins/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "2977827b8ecb3e15535236180e57dc35e85058d111349bdb6a1597e62a5068fb";
  };

  nativeBuildInputs = [
    gperf
    intltool
    itstool
  ];

  buildInputs = [
    avahi
    glib
    gmime
    #gnome-online-accounts
    gom
    grilo
    json-glib
    libarchive
    libgdata
    libmediaart
    liboauth
    libsoup
    libxml2
    lua
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
    # Remove dependency on webkit
    #(enFlag "goa" (gnome-online-accounts != null) null)
    "--disable-goa"
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

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/grilo-plugins/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A collection of plugins for the Grilo framework";
    homepage = https://wiki.gnome.org/action/show/Projects/Grilo;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
