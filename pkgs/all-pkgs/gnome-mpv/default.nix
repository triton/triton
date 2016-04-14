{ stdenv
, autoconf
, autoconf-archive
, automake
, fetchFromGitHub
, gettext
, intltool
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
, mpv
, pythonPackages
, wayland
, xorg
}:

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "gnome-mpv-${version}";
  version = "2016-04-11";

  src = fetchFromGitHub {
    owner = "gnome-mpv";
    repo = "gnome-mpv";
    rev = "00a48df85e6c19064c28e2a616a826fae919b78c";
    sha256 = "b35859c3124141aef7d69efe70c6cc04c5bf8304dfe12829fe51c8e1c58b6d9e";
  };

  nativeBuildInputs = [
    autoconf
    autoconf-archive
    automake
    dconf
    gettext
    intltool
    libtool
    makeWrapper
    pkgconfig
  ];

  buildInputs = [
    adwaita-icon-theme
    appstream-glib
    gdk-pixbuf
    glib
    gtk3
    libepoxy
    librsvg
    mpv
    pythonPackages.youtube-dl
    wayland
    xorg.libX11
  ];

  preConfigure =
    /* Ignore autogen.sh and run the commands manually */ ''
      aclocal --install -I m4
      intltoolize --copy --automake
      autoreconf --install -Wno-portability
    '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-schemas-compile"
    "--disable-debug"
    "--enable-opencl-cb"
    (enFlag "appstream-util" (appstream-glib != null) null)
  ];

  preFixup = ''
    wrapProgram $out/bin/gnome-mpv  \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with stdenv.lib; {
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