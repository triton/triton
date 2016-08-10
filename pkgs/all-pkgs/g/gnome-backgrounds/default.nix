{ stdenv
, fetchurl
, gettext
, intltool
}:

stdenv.mkDerivation rec {
  name = "gnome-backgrounds-${version}";
  versionMajor = "3.20";
  #versionMinor = "0";
  version = "${versionMajor}"; #.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-backgrounds/${versionMajor}/" +
          "${name}.tar.xz";
    sha256 = "d66c6e165e5c16b79ee4ab83102fa73fa20ce4e14191036ee68e8e82cf537127";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
  ];

  meta = with stdenv.lib; {
    description = "A set of backgrounds packaged with the GNOME desktop";
    homepage = https://git.gnome.org/browse/gnome-backgrounds;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
