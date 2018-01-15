{ stdenv
, autoreconfHook
, fetchurl
, gnome-common
, gtk-doc
, lib

, gtk_2
}:

# TODO: disable gtk-doc (needed for autoreconf currently)

stdenv.mkDerivation rec {
  name = "gtkimageview-1.6.4";

  src = fetchurl {
    url = "mirror://gentoo/distfiles/${name}.tar.gz";
    sha256 = "4c681d38d127ee3950a29bce9aa7aa8a2abe3b4d915f7a0c88e526999c1a46f2";
  };

  nativeBuildInputs = [
    autoreconfHook
    gnome-common
    gtk-doc
  ];

  buildInputs = [
    gtk_2
  ];

  postPatch =
    /* Prevent excessive build failures due to gcc/glib/gtk changes */ ''
      sed -i configure.in \
        -e '/CFLAGS/s/-Werror //g' \
        -e '/DEPRECATED_FLAGS/d'
    '' + /* Gold linker fix */ ''
      sed -i tests/Makefile.am \
        -e '/libtest.la/s:$: -lm:g'
    '';

  configureFlags = [
    "--disable-iso-c"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Image viewer widget for GTK+";
    homepage = https://projects.gnome.org/gtkimageview/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
