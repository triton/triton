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
  version = "2019-02-25";
in
stdenv.mkDerivation rec {
  name = "celluloid-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "celluloid-player";
    repo = "celluloid";
    rev = "51821c02019a3e1fa6e280001952840ca79f82d9";
    sha256 = "128fd9f34db5a9e57e8396d031ddc6dc607e976684e42f64d3646decf78a36d3";
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
    homepage = https://github.com/celluloid-player/celluloid;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
