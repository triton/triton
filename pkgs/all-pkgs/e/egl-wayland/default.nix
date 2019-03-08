{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja

, eglexternalplatform
, libx11
, opengl-dummy
, wayland
, xorgproto
}:

let
  version = "2019-01-23";
in
stdenv.mkDerivation rec {
  name = "egl-wayland-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "NVIDIA";
    repo = "egl-wayland";
    rev = "c81f849fc08e36fc5b94031b6edc361ab5027fce";
    sha256 = "ed32293d614a3b1b4065122837e61dcf838c2ddbe61c59cf335ce5a668730c2b";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    eglexternalplatform
    libx11
    opengl-dummy
    wayland
    xorgproto
  ];

  meta = with lib; {
    description = "Wayland EGL External Platform library";
    homepage = https://github.com/NVIDIA/egl-wayland;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
