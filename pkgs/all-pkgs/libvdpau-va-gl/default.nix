{ stdenv
, cmake
, fetchFromGitHub
, ninja

, libva
, mesa
, xorg
}:

let
  version = "0.4.0";
in

stdenv.mkDerivation rec {
  name = "libvdpau-va-gl-${version}";

  src = fetchFromGitHub {
    owner = "i-rinat";
    repo = "libvdpau-va-gl";
    rev = "v" + version;
    sha256 = "1c7bd460cdf977b78bf6c2c821d15dec039c2f12ab2c5de612aa291093634539";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libva
    mesa
    xorg.libX11
    xorg.xproto
  ];

  meta = with stdenv.lib; {
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
