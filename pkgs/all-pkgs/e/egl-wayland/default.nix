{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja

#, egl-headers
, eglexternalplatform
, libx11
, opengl-dummy
, wayland
, xorgproto
}:

let
  version = "2018-06-25";
in
stdenv.mkDerivation rec {
  name = "egl-wayland-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "NVIDIA";
    repo = "egl-wayland";
    rev = "395ce9f609fbf66f6cab622aec3ded663e089f84";
    sha256 = "8fdd323190a8a0cdc786c6414874a3eff0736cabba281b610e08b81dcca16c6b";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    #egl-headers  # Vendored by Mesa ATM
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
