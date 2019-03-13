{ stdenv
, fetchFromGitHub
, lib
, ncurses
, python3

, dbus
, fontconfig
, harfbuzz_lib
, libpng
, libx11
, libxcursor
, libxi
, libxinerama
, libxkbcommon
, libxrandr
, opengl-dummy
, wayland
, wayland-protocols
}:

let
  version = "0.13.3";
in
stdenv.mkDerivation rec {
  name = "kitty-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "kovidgoyal";
    repo = "kitty";
    rev = "v${version}";
    sha256 = "f25224c0a5b0c6f32662d31452fd6fed1665e37f2a1acd193e1a8a838e86185f";
  };

  nativeBuildInputs = [
    ncurses
    python3
  ];

  buildInputs = [
    dbus
    fontconfig
    harfbuzz_lib
    libpng
    libx11
    libxcursor
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    opengl-dummy
    wayland
    wayland-protocols
  ];

  postPatch = ''
    # Don't build docs.
    mkdir -pv docs/_build/html
    sed -i setup.py \
      -e '/copy_man_pages(ddir)$/d' \
      -e '/copy_html_docs(ddir)$/d'
  '';

  buildPhase = ":";

  installPhase = ''
    python3 setup.py linux-package --verbose --prefix "$out"
  '';

  meta = with lib; {
    description = "Fast, featureful, GPU based, terminal emulator";
    homepage = https://sw.kovidgoyal.net/kitty/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
