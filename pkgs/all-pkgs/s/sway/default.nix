{ stdenv
, fetchFromGitHub
, meson
, ninja
, scdoc

, cairo
, gdk-pixbuf
, json-c
, libevdev
, libinput
, libxcb
, libxkbcommon
, pango
, pcre
, systemd_lib
, wayland
, wayland-protocols
, wlroots
, xorg
}:

let
  version = "1.0-rc5";
in
stdenv.mkDerivation rec {
  name = "sway-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "swaywm";
    repo = "sway";
    rev = version;
    sha256 = "e0b79f3022a37e83a2b323f64a804ffb206e942ed9433f5a08c92ef4a1f2cc4c";
  };

  nativeBuildInputs = [
    meson
    ninja
    scdoc
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    json-c
    libevdev
    libinput
    libxcb
    libxkbcommon
    pango
    pcre
    systemd_lib
    wayland
    wayland-protocols
    wlroots
    xorg.pixman
  ];

  # We need to set the SRC_DIR otherwise we have impurities
  NIX_CFLAGS_COMPILE = "-USWAY_SRC_DIR -DSWAY_SRC_DIR=\"/no-such-path\"";
  postPatch = ''
    grep -q 'SWAY_SRC_DIR' meson.build
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
