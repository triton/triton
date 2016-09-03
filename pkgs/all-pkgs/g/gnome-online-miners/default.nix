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
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/gnome-online-miners/${versionMajor}/" +
          "${name}.tar.xz";
    sha256 = "f46dac7743283385d2aeea588eeead216274d9f365e323b90f586de982336e36";
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
