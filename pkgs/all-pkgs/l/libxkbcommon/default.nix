{ stdenv
, bison
, fetchurl
, flex
, meson
, ninja

, wayland
, wayland-protocols
, xorg
}:

stdenv.mkDerivation rec {
  name = "libxkbcommon-0.7.2";

  src = fetchurl {
    url = "https://xkbcommon.org/download/${name}.tar.xz";
    multihash = "QmZFWeRWKZQxRxVDa3Hswd6QQn5YtJXMM4PW5PWEDA1ha2";
    hashOutput = false;
    sha256 = "28a4dc2735863bec2dba238de07fcdff28c5dd2300ae9dfdb47282206cd9b9d8";
  };

  nativeBuildInputs = [
    bison
    flex
    meson
    ninja
  ];

  buildInputs = [
    wayland
    wayland-protocols
    xorg.libxcb
    xorg.xkeyboardconfig
  ];

  mesonFlags = [
    "-Denable-docs=false"
  ];

  meta = with stdenv.lib; {
    description = "A library to handle keyboard descriptions";
    homepage = https://xkbcommon.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

