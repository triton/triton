{ stdenv
, autoconf
, automake
, docbook2x
, fetchFromGitHub
, gettext
, glib
, gnome-common
, gobject-introspection
, intltool
, itstool
, libtool
, libxml2
, perlPackages
, which
, yelp-tools

, appstream-glib
, colord
, colord-gtk
, gtk3
, lcms
, libcanberra
, libgusb
, libsoup
}:

let
  date = "2017-10-14";
  rev = "e61616792138ee38718e22508558d41fc14bfbf6";
in
stdenv.mkDerivation rec {
  name = "colorhug-client-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "hughski";
    repo = "colorhug-client";
    inherit rev;
    sha256 = "348cca86cca18a281dd36dfe7aaa0f242c7a69cb04599b9049d243d9a77b0d8e";
  };

  nativeBuildInputs = [
    autoconf
    automake
    docbook2x
    gettext
    glib
    gnome-common
    gobject-introspection
    intltool
    itstool
    libtool
    libxml2
    perlPackages.perl
    perlPackages.XMLLibXML
    perlPackages.XMLSAX
    perlPackages.XMLSAXBase
    perlPackages.XMLSAXExpat
    which
    yelp-tools
  ];

  buildInputs = [
    appstream-glib
    colord
    colord-gtk
    glib
    gtk3
    lcms
    libcanberra
    libgusb
    libsoup
  ];

  postPatch = ''
    sed -i 's,docbook2man,docbook2man --sgml,g' man/Makefile.am
  '';

  preConfigure = ''
    NOCONFIGURE=1 ./autogen.sh
  '';

  configureFlags = [
    "--disable-bash-completion"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
