{ stdenv
#, autoreconfHook
, fetchurl
, gettext
#, gnome-common

, atk
, cairo
, gdk-pixbuf
, glib
, gobject-introspection
, gtk3
, libffi
, libxml2
, pango
, readline
, spidermonkey_24
, xorg
}:

let
  inherit (stdenv.lib)
    wtFlag;
in
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
    #autoreconfHook
    gettext
    #gnome-common
  ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    glib
    gobject-introspection
    gtk3
    libffi
    libxml2
    pango
    readline
    spidermonkey_24
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-cxx-warnings"
    "--disable-iso-cxx"
    "--disable-coverage"
    "--disable-installed-tests"
    "--disable-systemtap"
    "--disable-dtrace"
    "--enable-Bsymbolic"
    (wtFlag "cairo" (cairo != null) null)
    (wtFlag "gtk" (gtk3 != null) null)
  ];

  postInstall = ''
    sed -i $out/lib/libgjs.la \
      -e 's|-lreadline|-L${readline}/lib -lreadline|g'
  '' + /* Remove empty directory tree (for installed tests)) */ ''
    rm -frv $out/libexec
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
    platforms = with platforms;
      x86_64-linux;
  };

}
