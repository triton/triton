{ stdenv
, fetchFromGitHub
, gettext
, intltool
, lib
, makeWrapper
, meson
, ninja
, python3Packages

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
, shared-mime-info
, wayland
}:

let
  version = "2018-08-19";
in
stdenv.mkDerivation rec {
  name = "gnome-mpv-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "gnome-mpv";
    repo = "gnome-mpv";
    rev = "7aea4058a28529baf2a51931cfb9bf83d2d519e0";
    sha256 = "203f399fb384c8ba9cf5c79283c9fd8ee901e5b47cd3d7f2afa0fb1fc24d0534";
  };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
    meson
    ninja
    python3Packages.python
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
    python3Packages.youtube-dl
    shared-mime-info
    wayland
  ];

  postPatch = ''
    patchShebangs src/generate_authors.py
  '' + /* Post-install is already handled by setup-hooks */ ''
    sed -i meson.build \
      -e '/meson_post_install.py/d'
  '';

  preFixup = ''
    wrapProgram $out/bin/gnome-mpv  \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

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
