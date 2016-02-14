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
  versionMajor = "3.14";
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-online-miners/${versionMajor}/" +
          "${name}.tar.xz";
    sha256 = "0zdsb56b14xjlanc4ihjkhnjk7f3ph2jv6g3x4mpdjsg5wfhqzwh";
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
      i686-linux
      ++ x86_64-linux;
  };
}
