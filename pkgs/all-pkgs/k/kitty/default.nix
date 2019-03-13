{ stdenv
, fetchurl
, lib
, ncurses
, python3

, dbus
, fontconfig
, freetype
, harfbuzz_lib
, libpng
, libx11
, libxcb
, libxcursor
, libxi
, libxinerama
, libxkbcommon
, libxrandr
, opengl-dummy
, wayland
, wayland-protocols
, zlib
}:

let
  version = "0.13.3";
in
stdenv.mkDerivation rec {
  name = "kitty-${version}";

  src = fetchurl {
    url = "https://github.com/kovidgoyal/kitty/releases/download/v${version}/"
      + "${name}.tar.xz";
    sha256 = "37b90f3467c31ee9f0338c066563ab2ec2eac56267286bc4ef6d9850f97f1507";
  };

  nativeBuildInputs = [
    ncurses
    python3
  ];

  buildInputs = [
    dbus
    fontconfig
    freetype
    harfbuzz_lib
    libpng
    libx11
    libxcb
    libxcursor
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    opengl-dummy
    wayland
    wayland-protocols
    zlib
  ];

  postPatch = ''
    # Don't build docs.
    mkdir -pv docs/_build/html/
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
