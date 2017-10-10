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
, xproto
}:

let
  date = "2017-10-07";
  rev = "328edc089915aeb5cf26e5fc0e81b307ec707d62";
in
stdenv.mkDerivation rec {
  name = "wlc-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "Cloudef";
    repo = "wlc";
    inherit rev;
    sha256 = "01303544a3ca64e6510eb12d645ee14a879182789c13e861410ca393b6251e95";
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
    xproto
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
