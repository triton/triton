{ stdenv
, fetchurl

, glib
, libxml2
}:

stdenv.mkDerivation rec {
  name = "libcroco-${version}";
  versionMajor = "0.6";
  versionMinor = "11";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/libcroco/${versionMajor}/${name}.tar.xz";
    sha256 = "0mm0wldbi40am5qn0nv7psisbg01k42rwzjxl3gv11l5jj554aqk";
  };

  buildInputs = [
    libxml2
    glib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-checks"
    "--enable-Bsymbolic"
  ];

  meta = with stdenv.lib; {
    description = "Generic Cascading Style Sheet (CSS) parsing and manipulation";
    homepage = https://git.gnome.org/browse/libcroco/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
