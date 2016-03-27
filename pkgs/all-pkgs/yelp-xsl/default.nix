{ stdenv
, fetchurl
, gawk
, intltool
, itstool
, gettext

, libxml2
, libxslt
}:

stdenv.mkDerivation rec {
  name = "yelp-xsl-${version}";
  versionMajor = "3.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/yelp-xsl/${versionMajor}/${name}.tar.xz";
    sha256 = "9f327887853c40d7332dde8789ee58c0cf678186719cb905e57ae175b8434848";
  };

  nativeBuildInputs = [
    gawk
    intltool
    itstool
    gettext
  ];

  buildInputs = [
    libxml2
    libxslt
  ];

  configureFlags = [
    "--enable-nls"
    "--disable-doc"
  ];

  meta = with stdenv.lib; {
    description = "XSL stylesheets for yelp";
    homepage = https://git.gnome.org/browse/yelp-xsl;
    license = with licenses; [
      fdl11
      gpl2Plus
      lgpl21Plus
      mit
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
