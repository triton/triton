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
  version = "2019-07-06";
in
stdenv.mkDerivation rec {
  name = "celluloid-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "celluloid-player";
    repo = "celluloid";
    rev = "6e5cd81065da0d2b61f2df7f90fb4602d3b8c69b";
    sha256 = "fdd6d2bdf4421b390778c939edb1fea4baf706d562f90aaeff5af567a1353734";
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
    wrapProgram $out/bin/celluloid  \
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
