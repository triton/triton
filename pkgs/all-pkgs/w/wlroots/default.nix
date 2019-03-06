{ stdenv
, fetchFromGitHub
, meson
, ninja

, libcap
, libdrm
, libinput
, libx11
, libxcb
, libxkbcommon
, opengl-dummy
, systemd_lib
, wayland
, wayland-protocols
, xorg
, xorgproto
}:

let
  version = "0.4.1";
in
stdenv.mkDerivation {
  name = "wlroots-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "swaywm";
    repo = "wlroots";
    rev = version;
    sha256 = "973fd1ecdac73041f9e120942b3e3d75eab9da0088bcf60a203fb73dfd0413a8";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    libcap
    libdrm
    libinput
    libx11
    libxcb
    libxkbcommon
    opengl-dummy
    systemd_lib
    wayland
    wayland-protocols
    xorg.xcbutilerrors
    xorg.xcbutilwm
    xorgproto
    xorg.pixman
  ];

  # We need to set the SRC_DIR otherwise we have impurities
  NIX_CFLAGS_COMPILE = "-UWLR_SRC_DIR -DWLR_SRC_DIR=\"/no-such-path\"";
  postPatch = ''
    grep -q 'WLR_SRC_DIR' meson.build
  '';

  mesonFlags = [
    "-Drootson=false"
    "-Dexamples=false"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
