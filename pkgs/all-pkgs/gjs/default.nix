{ stdenv
, fetchurl
, gettext

, atk
, cairo
, gdk-pixbuf
, glib
, gnome-common
, gobject-introspection
, gtk3
, libffi
, libxml2
, pango
, readline
, spidermonkey_24
, xorg
}:

with {
  inherit (stdenv.lib)
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "gjs-${version}";
  versionMajor = "1.44";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gjs/${versionMajor}/${name}.tar.xz";
    sha256 = "106fgpr4y99sj68l72pnfa2za11ps4bn6p9z28fr79j7mpv61jc8";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    glib
    gnome-common
    gobject-introspection
    gtk3
    libffi
    libxml2
    pango
    readline
    spidermonkey_24
  ];

  configureFlags = [
    "--enable-cxx-warnings"
    "--disable-coverage"
    "--disable-systemtap"
    "--disable-dtrace"
    "--enable-Bsymbolic"
    (wtFlag "cairo" (cairo != null) null)
    (wtFlag "gtk" (gtk3 != null) null)
  ];

  postInstall = ''
    sed -i $out/lib/libgjs.la \
      -e 's|-lreadline|-L${readline}/lib -lreadline|g'
  '';

  meta = with stdenv.lib; {
    description = "Javascript bindings for GNOME";
    homepage = https://wiki.gnome.org/Projects/Gjs;
    license = with licenses; [
      gpl2Plus
      lgpl2Plus
      mit
      mpl11
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
