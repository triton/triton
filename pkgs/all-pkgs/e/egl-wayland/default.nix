{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib

#, egl-headers
, eglexternalplatform
, libx11
, opengl-dummy
, wayland
, xorgproto
}:

let
  version = "2017-08-01";
in
stdenv.mkDerivation rec {
  name = "egl-wayland-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "NVIDIA";
    repo = "egl-wayland";
    rev = "1f4b1fde684595fe28e250b7429e028a7bb7d40d";
    sha256 = "b84943ef5b555cb08ef3daa068c217963977ddfd6617c1aca219d766b9ecc0a7";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    #egl-headers  # Vendored by Mesa ATM
    eglexternalplatform
    libx11
    opengl-dummy
    wayland
    xorgproto
  ];

  configureFlags = [
    "--disable-debug"
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
