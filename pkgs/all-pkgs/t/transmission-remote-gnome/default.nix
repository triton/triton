{ stdenv
, appstream-glib
, fetchFromGitHub
, intltool
, isPy3
, lib
, makeWrapper
, meson
, ninja

, adwaita-icon-theme
, atk
, dconf
, gdk-pixbuf
, glib
, gobject-introspection
, gtk
, libsoup
, pango
, pygobject
, python
, shared-mime-info
}:

# TODO: compile python files

assert isPy3;

let
  inherit (lib)
    makeSearchPath;

  version = "2017-06-04";
in
stdenv.mkDerivation rec {
  name = "transmission-remote-gnome-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "TingPing";
    repo = "transmission-remote-gnome";
    rev = "b415208bbb0b2e4ef7eb38a784b26bbe808d6a2c";
    sha256 = "8502f0f0e001b1a5d9df52d228221f1de9c59637f679fff419aa7abb7a9c2dbb";
  };

  nativeBuildInputs = [
    appstream-glib
    intltool
    makeWrapper
    meson
    ninja
  ];

  propagatedBuildInputs = [
    adwaita-icon-theme
    atk
    dconf
    gdk-pixbuf
    glib
    gobject-introspection
    gtk
    libsoup
    pango
    pygobject
    python
  ];

  pythonPath = propagatedBuildInputs;

  postPatch = ''
    sed -i meson.build \
      -e '/meson_post_install.py/d'
  '';

  preFixup = ''
    export PYTHONPATH
    wrapProgram $out/bin/transmission-remote-gnome \
      --prefix 'PYTHONPATH' : "$PYTHONPATH" \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
      --prefix 'LD_LIBRARY_PATH' : "${makeSearchPath "lib" propagatedBuildInputs}" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with lib; {
    description = "Remote client for the Transmission torrent daemon";
    homepage = https://github.com/TingPing/transmission-remote-gnome;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
