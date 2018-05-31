{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja

, libva
, libx11
, opengl-dummy
, xorgproto
}:

let
  version = "0.4.2";
in
stdenv.mkDerivation rec {
  name = "libvdpau-va-gl-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "i-rinat";
    repo = "libvdpau-va-gl";
    rev = "v${version}";
    sha256 = "32bbc4aa57ca3c9cc5824e0bbec3e59e6dda5a33d2bb2ef4955ce15b7d61f3fe";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libva
    libx11
    opengl-dummy
    xorgproto
  ];

  meta = with lib; {
    description = "VDPAU driver with OpenGL/VAAPI backend";
    homepage = https://github.com/i-rinat/libvdpau-va-gl;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
