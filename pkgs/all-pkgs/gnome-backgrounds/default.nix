{ stdenv
, fetchurl
, gettext
, intltool
}:

stdenv.mkDerivation rec {
  name = "gnome-backgrounds-${version}";
  versionMajor = "3.18";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-backgrounds/${versionMajor}/" +
          "${name}.tar.xz";
    sha256 = "aa560f0e5f12a308dd36aaac2fff32916abd61d42f47b4bc42c8c7011bf2a7b9";
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
      i686-linux
      ++ x86_64-linux;
  };
}
