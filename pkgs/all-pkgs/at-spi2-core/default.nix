{ stdenv
, fetchurl
, intltool
, python

, dbus
, dbus-glib
, glib
, gobject-introspection
, xorg
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

assert xorg != null ->
  xorg.libSM != null
  && xorg.libX11 != null
  && xorg.libXi != null
  && xorg.libXtst != null;

stdenv.mkDerivation rec {
  name = "at-spi2-core-${version}";
  versionMajor = "2.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/at-spi2-core/${versionMajor}/${name}.tar.xz";
    sha256 = "dcc49fb7c08e582910b21ff1e4110b22ab66068a4c6f0db52b098d66794c609b";
  };

  nativeBuildInputs = [
    intltool
    python
  ];

  buildInputs = [
    dbus
    dbus-glib
    glib
    gobject-introspection
    xorg.libSM
    xorg.libX11
    xorg.libXi
    xorg.libXtst
  ];

  configureFlags = [
    "--enable-nls"
    (enFlag "x11" (xorg != null) null)
    # xevie is deprecated/broken since xorg-1.6/1.7
    "--disable-xevie"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (wtFlag "x" (xorg != null) null)
    "--with-dbus-daemondir=/run/current-system/sw/bin/"
  ];

  meta = with stdenv.lib; {
    description = "D-Bus accessibility specifications and registration daemon";
    homepage = https://wiki.gnome.org/Accessibility;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
