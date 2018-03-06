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
  date = "2017-10-14";
  rev = "e3abf0b2f322b9d376ced452190cd4dd9f6fcb8a";
in
stdenv.mkDerivation rec {
  name = "wlc-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "Cloudef";
    repo = "wlc";
    inherit rev;
    sha256 = "54aa8a91f26fad6c30ce2f26484b18a40b20aac86de24814b964e7b3d81c8fa8";
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
