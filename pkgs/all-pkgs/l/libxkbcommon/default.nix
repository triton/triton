{ stdenv
, bison
, fetchurl
, flex
, lib
, meson
, ninja

, libxcb
, wayland
, wayland-protocols
, xkeyboard-config
}:

stdenv.mkDerivation rec {
  name = "libxkbcommon-0.8.0";

  src = fetchurl {
    url = "https://xkbcommon.org/download/${name}.tar.xz";
    multihash = "QmekLKEnvMuurHJ1JbaiZ4LCJUg39CwTR6RkryLDPN12bU";
    hashOutput = false;
    sha256 = "e829265db04e0aebfb0591b6dc3377b64599558167846c3f5ee5c5e53641fe6d";
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
