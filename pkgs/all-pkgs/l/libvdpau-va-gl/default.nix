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
    version = 2;
    owner = "i-rinat";
    repo = "libvdpau-va-gl";
    rev = "v" + version;
    sha256 = "1c5c03239f56e1092d273f822396a6c1103a100d737d425a67662892eb0b5d51";
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
