{ stdenv
, fetchurl

, gawk
, itstool
, libxml2
, libxslt
, yelp-xsl
}:

stdenv.mkDerivation rec {
  name = "yelp-tools-${version}";
  versionMajor = "3.18";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/yelp-tools/${versionMajor}/${name}.tar.xz";
    sha256 = "c6c1d65f802397267cdc47aafd5398c4b60766e0a7ad2190426af6c0d0716932";
  };

  buildInputs = [
    gawk
    itstool
    libxml2
    libxslt
    yelp-xsl
  ];

  meta = with stdenv.lib; {
    description = "Collection of tools for building & converting documentation";
    homepage = https://wiki.gnome.org/Apps/Yelp/Tools;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}