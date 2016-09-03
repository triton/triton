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
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/yelp-xsl/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/yelp-xsl/${versionMajor}/${name}.sha256sum";
    sha256 = "dc61849e5dca473573d32e28c6c4e3cf9c1b6afe241f8c26e29539c415f97ba0";
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
