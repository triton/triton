{ stdenv
, autoconf
, autoconf-archive
, automake
, fetchFromGitHub
, gettext
, intltool
, lib
, libtool
, makeWrapper
, pkgconfig

, adwaita-icon-theme
, appstream-glib
, dconf
, gdk-pixbuf
, glib
, gtk3
, libepoxy
, librsvg
, libx11
, mpv
, python2Packages
, shared-mime-info
, wayland
}:

let
  inherit (lib)
    boolEn;

  version = "2017-08-10";
in
stdenv.mkDerivation rec {
  name = "gnome-mpv-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "gnome-mpv";
    repo = "gnome-mpv";
    rev = "2e13ab37fffdb2124d62872994de6b79a128f9cb";
    sha256 = "cbd5d22ba1722e980f59290ebcdb0ed8a4351631e4010bc2c337344de89e7934";
  };

  nativeBuildInputs = [
    autoconf
    autoconf-archive
    automake
    gettext
    intltool
    libtool
    makeWrapper
    pkgconfig
  ];

  buildInputs = [
    adwaita-icon-theme
    appstream-glib
    dconf
    gdk-pixbuf
    glib
    gtk3
    libepoxy
    librsvg
    libx11
    mpv
    python2Packages.youtube-dl
    shared-mime-info
    wayland
  ];

  preConfigure = /* Ignore autogen.sh and run the commands manually */ ''
    aclocal --install -I m4
    intltoolize --copy --automake
    autoreconf --force --install -Wno-portability
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-schemas-compile"
    "--disable-debug"
    "--enable-opencl-cb"
    "--enable-appstream-util"
  ];

  preFixup = ''
    wrapProgram $out/bin/gnome-mpv  \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  parallelBuild = false;

  meta = with lib; {
    description = "A simple GTK+ frontend for mpv";
    homepage = https://github.com/gnome-mpv/gnome-mpv;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
