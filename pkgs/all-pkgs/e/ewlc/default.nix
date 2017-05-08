{ stdenv
, cmake
, fetchFromGitHub
, ninja

, chck
, dbus
, libdrm
, libinput
, libxkbcommon
, mesa_noglu
, systemd_lib
, wayland
, wayland-protocols
, xorg
}:

let
  date = "2017-05-07";
  rev = "8b280f7091af80852a6575f24e7a79d218a9840d";
in
stdenv.mkDerivation rec {
  name = "ewlc-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "Enerccio";
    repo = "ewlc";
    inherit rev;
    sha256 = "e5b3b18697518d84404530a69d09d15b667c3bb20abeb2dd6cc73b2cd7304c39";
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
    libxkbcommon
    mesa_noglu
    systemd_lib
    wayland
    wayland-protocols
    xorg.fixesproto
    xorg.libX11
    xorg.libxcb
    xorg.libXfixes
    xorg.pixman
    xorg.xcbutilimage
    xorg.xcbutilwm
    xorg.xproto
  ];

  cmakeFlags = [
    "-DWLC_BUILD_EXAMPLES=OFF"
    "-DWLC_BUILD_TESTS=OFF"
  ];

  # Make libwlc compatible links
  postInstall = ''
    pushd "$out" >/dev/null
    for lib in $(find lib64 -name \*ewlc\*); do
      ln -sv "$(basename "$lib")" "$(echo "$lib" | sed 's,ewlc,wlc,g')"
    done
    popd >/dev/null
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
