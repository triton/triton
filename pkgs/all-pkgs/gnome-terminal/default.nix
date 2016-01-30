{ stdenv
, desktop_file_utils
, fetchurl
, gnome_doc_utils
, intltool
, itstool
, libuuid
, libxml2
, which

, appdata-tools
, dconf
, glib
, gsettings-desktop-schemas
, gtk3
, nautilus
, vala
, vte
, xorg
}:

stdenv.mkDerivation rec {
  name = "gnome-terminal-${version}";
  versionMajor = "3.18";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-terminal/${versionMajor}/${name}.tar.xz";
    sha256 = "1ylyv0mla2ypms7iyxndbdjvha0q9jzglb4mhfmqn9cm2gxc0day";
  };

  nativeBuildInputs = [
    desktop_file_utils
    gnome_doc_utils
    intltool
    itstool
    libuuid
    libxml2
    which
  ];

  buildInputs = [
    appdata-tools
    dconf
    glib
    gsettings-desktop-schemas
    gtk3
    nautilus
    vala
    vte
    xorg.libX11
  ];

  configureFlags = [
    "--disable-search-provider"
    "--disable-migration"
  ];

  preFixup = ''
    gnomeWrapperArgs+=(
      "--prefix GIO_EXTRA_MODULES : ${dconf}/lib/gio/modules"
    )
  '';

  meta = with stdenv.lib; {
    description = "The Gnome Terminal";
    homepage = https://wiki.gnome.org/Apps/Terminal/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
