{ stdenv
, fetchurl
, gettext
, lib

, atk
, glib
, gtk_2
, libxml2
, python2
}:

let
  channel = "2.6";
  version = "${channel}.4";
in
stdenv.mkDerivation rec {
  name = "libglade-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libglade/${channel}/${name}.tar.bz2";
    sha256 = "64361e7647839d36ed8336d992fd210d3e8139882269bed47dc4674980165dec";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    atk
    glib
    gtk_2
    libxml2
    python2
  ];

  configureFlags = [
    "--disable-gtktest"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  meta = with lib; {
    description = "Library to construct graphical interfaces at runtime";
    homepage = https://library.gnome.org/devel/libglade/stable/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
