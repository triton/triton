{ stdenv
, bison
, fetchFromGitHub
, flex
, lib
, meson
, ninja

, libxcb
, wayland
, wayland-protocols
, xkeyboard-config
}:

let
  version = "0.8.3";
in
stdenv.mkDerivation rec {
  name = "libxkbcommon-${version}";

  # Not using fetchurl because their dist tarballs are broken for 0.8.3
  src = fetchFromGitHub {
    version = 6;
    owner = "xkbcommon";
    repo = "libxkbcommon";
    rev = "xkbcommon-${version}";
    sha256 = "421444cc3bbf9fb024f09f5748c19db167452ce6541b9af80f7b07b033072d31";
  };

  nativeBuildInputs = [
    bison
    flex
    meson
    ninja
  ];

  buildInputs = [
    libxcb
    wayland
    wayland-protocols
    xkeyboard-config
  ];

  mesonFlags = [
    "-Denable-docs=false"
  ];

  meta = with lib; {
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
