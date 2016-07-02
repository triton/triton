{ stdenv
, fetchurl
, gettext
, intltool

, gdk-pixbuf
, hicolor-icon-theme
}:

stdenv.mkDerivation rec {
  name = "adwaita-icon-theme-${version}";
  versionMajor = "3.20";
  #versionMinor = "0";
  version = "${versionMajor}"; #.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/adwaita-icon-theme/${versionMajor}/${name}.tar.xz";
    sha256 = "7a0a887349f340dd644032f89d81264b694c4b006bd51af1c2c368d431e7ae35";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  propagatedBuildInputs = [
    # For convenience, we specify adwaita-icon-theme only in packages
    hicolor-icon-theme
  ];

  buildInputs = [
    gdk-pixbuf
  ];

  configureFlags = [
    "--enable-nls"
    "--enable-w32-cursors"
    "--enable-l-xl-variants"
  ];

  preInstall = ''
    # Install fails to create these directories automatically
    mkdir -pv $out/share/icons/Adwaita-{,Extra}Large/cursors
  '';

  doCheck = false;

  meta = with stdenv.lib; {
    description = "GNOME default icon theme";
    homepage = https://git.gnome.org/browse/adwaita-icon-theme/;
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
