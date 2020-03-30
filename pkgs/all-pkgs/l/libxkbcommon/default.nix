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
}:

let
  version = "0.10.0";
in
stdenv.mkDerivation rec {
  name = "libxkbcommon-${version}";

  # Not using fetchurl because their dist tarballs are broken for 0.8.3
  src = fetchFromGitHub {
    version = 6;
    owner = "xkbcommon";
    repo = "libxkbcommon";
    rev = "xkbcommon-${version}";
    sha256 = "a9d1c193048ec123ca270bbd2e631acfb872dfb68ca5f823f85c91d0aae47254";
  };

  nativeBuildInputs = [
    bison
    #flex
    meson
    ninja
  ];

  buildInputs = [
    libxcb
    wayland
    wayland-protocols
  ];

  mesonFlags = [
    "-Denable-docs=false"
    "-Dxkb-config-root=/run/current-system/sw/share/X11/xkb"
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
