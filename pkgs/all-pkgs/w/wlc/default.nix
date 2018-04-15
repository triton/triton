{ stdenv
, cmake
, fetchFromGitHub
, ninja

, chck
, dbus
, libdrm
, libinput
, libx11
, libxcb
, libxfixes
, libxkbcommon
, opengl-dummy
, systemd_lib
, wayland
, wayland-protocols
, xorg
, xorgproto
}:

let
  date = "2017-12-28";
  rev = "6542c16652df147523245fc547d2a5ff4088a0cb";
in
stdenv.mkDerivation rec {
  name = "wlc-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "Cloudef";
    repo = "wlc";
    inherit rev;
    sha256 = "d1b00ef6e9d8a1e5dca095ac623b6daaa3715e0b2dd59e1a805216344bd927a9";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    chck
    dbus
    libdrm
    libinput
    libx11
    libxcb
    libxfixes
    libxkbcommon
    opengl-dummy
    systemd_lib
    wayland
    wayland-protocols
    xorg.pixman
    xorg.xcbutilimage
    xorg.xcbutilwm
    xorgproto
  ];

  cmakeFlags = [
    "-DWLC_BUILD_EXAMPLES=OFF"
    "-DWLC_BUILD_TESTS=OFF"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
