{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja

, libdrm
, libva
, libx11
, wayland
, xorgproto
}:

let
  date = "2018-04-28";
  rev = "40b15a5c6c0103c23a5db810aef27cf75d0b6723";
in
stdenv.mkDerivation rec {
  name = "intel-vaapi-driver-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "intel";
    repo = "intel-vaapi-driver";
    inherit rev;
    sha256 = "5ac5271ecd9918b3c95d265d0bdf27fd9cb5f5551757a4968a0600a42ff75761";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    libdrm
    libva
    libx11
    wayland
    xorgproto
  ];

  preConfigure = ''
    mesonFlagsArray+=("-Ddriverdir=$out/lib/dri")
  '';

  mesonFlags = [
    "-Dwith_x11=yes"
    "-Dwith_wayland=yes"
    "-Denable_hybrid_codec=true"
  ];

  meta = with lib; {
    description = "VA-API user mode driver for Intel GEN Graphics family";
    homepage = https://github.com/01org/intel-vaapi-driver;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
