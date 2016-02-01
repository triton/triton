{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool

, glib
, gobject-introspection
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gnome-menus-${version}";
  versionMajor = "3.13";
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-menus/${versionMajor}/${name}.tar.xz";
    sha256 = "0kk5dirr9n34yxxayv643d6yi5bm9635hkm0icmza79qzyw6wi3w";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    glib
    gobject-introspection
  ];

  patches = [
    (fetchTritonPatch {
      rev = "e7b7c5f328fda18bc43aa8bbf73520441295850b";
      file = "gnome-menus/gnome-menus-3.13.3-multiple-desktop.patch";
      sha256 = "f22defd228de353d0c45ff69570c9dc7bdf20831a87f54aeb5c9e5ab3df0d232";
    })
    (fetchTritonPatch {
      rev = "e7b7c5f328fda18bc43aa8bbf73520441295850b";
      file = "gnome-menus/gnome-menus-3.13.3-multiple-desktop2.patch";
      sha256 = "2693e4f411e6b9a5f1f93bf3aaae70e88e23ae5139c00084e1154d489b1a48de";
    })
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--enable-deprecation-flags"
    "--disable-debug"
    (enFlag "introspection" (gobject-introspection != null) null)
  ];

  makeFlags = [
    "INTROSPECTION_GIRDIR=$(out)/share/gir-1.0/"
    "INTROSPECTION_TYPELIBDIR=$(out)/lib/girepository-1.0"
  ];

  meta = with stdenv.lib; {
    description = "Library for the Desktop Menu fd.o specification";
    homepage = https://git.gnome.org/browse/gnome-menus;
    license = with licenses; [
      gpl2Plus
      lgpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
