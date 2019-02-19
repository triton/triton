{ stdenv
, fetchFromGitHub
, gettext
, lib
, meson
, ninja
, vala

, atk
, gdk-pixbuf
, glib
, gobject-introspection
, gtk3
, hicolor-icon-theme
, libgee
, pango
}:

let
  version = "5.2.3";
in
stdenv.mkDerivation rec {
  name = "granite-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "elementary";
    repo = "granite";
    rev = "${version}";
    sha256 = "a1dc84ade412754d7c3b293834bf652040a6f0531f381ebc2435a01c300465c2";
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
    vala
  ];

  buildInputs = [
    atk
    gdk-pixbuf
    glib
    libgee
    gobject-introspection
    gtk3
    hicolor-icon-theme
    pango
  ];

  postPatch = ''
    grep -q 'post_install.py' meson.build
    sed -i meson.build \
      -e '/add_install_script/,+3 d'
  '';

  buildDirCheck = false;
  setVapidirInstallFlag = false;

  meta = with lib; {
    description = "An extension to GTK+ used by elementary OS";
    homepage = https://github.com/elementary/granite/;
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
