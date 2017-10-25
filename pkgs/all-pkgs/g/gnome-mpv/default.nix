{ stdenv
, fetchFromGitHub
, gettext
, intltool
, lib
, makeWrapper
, meson
, ninja
, python3

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

  version = "2017-10-23";
in
stdenv.mkDerivation rec {
  name = "gnome-mpv-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "gnome-mpv";
    repo = "gnome-mpv";
    rev = "0f3c23f0d752af1eff7dec7ca95143e4b4f1eb97";
    sha256 = "acdf223aad33b507732d5d67838070ddec360d31ce6132a4d5bcd90711310443";
  };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
    meson
    ninja
    python3
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

  postPatch = ''
    patchShebangs src/generate_authors.py
  '' + /* Post-install is already handled by setup-hooks */ ''
    sed -i meson.build \
      -e '/meson_post_install.py/d'
  '';

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
