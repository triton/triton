{ stdenv
, fetchurl

, glib
, gnome-online-accounts
, grilo
, grilo-plugins
, json-glib
, libgdata
, libgfbgraph
, libzapojit
, tracker
}:

stdenv.mkDerivation rec {
  name = "gnome-online-miners-${version}";
  versionMajor = "3.20";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-online-miners/${versionMajor}/" +
          "${name}.tar.xz";
    sha256 = "791b89289781272c001545931a8f58f499d14e46e038a9caa82dfe2494301afd";
  };

  buildInputs = [
    glib
    gnome-online-accounts
    grilo
    grilo-plugins
    libgdata
    libgfbgraph
    libzapojit
    tracker
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-debug"
    "--enable-facebook"
    "--enable-flickr"
    "--enable-google"
    "--enable-media-server"
    "--enable-owncloud"
    "--enable-windows-live"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Crawls through your online content";
    homepage = https://wiki.gnome.org/Projects/GnomeOnlineMiners;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
