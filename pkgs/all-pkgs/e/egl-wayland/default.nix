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
  version = "2018-01-31";
in
stdenv.mkDerivation rec {
  name = "egl-wayland-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "NVIDIA";
    repo = "egl-wayland";
    rev = "68ffe6fff49fff7667e8bab5b743c3e6c1950a6f";
    sha256 = "89f67cc9fd6082466d75449d3b496f2eae3e9dc0fe0f8b79d49c444e6acab9f2";
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

  postPatch = ''
    # Fix list being cast to a string
    sed -i meson.build \
      -e '/EGL_EXTERNAL_PLATFORM_MAX_VERSION/ s/\[//' \
      -e '/EGL_EXTERNAL_PLATFORM_MAX_VERSION/ s/\]//'
  '';

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
