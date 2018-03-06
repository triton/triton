{ stdenv
, cmake
, fetchFromGitHub
, lib
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
  date = "2017-06-19";
  rev = "b4095c75b99b604c934b69f57017798bb0338c1b";
in
stdenv.mkDerivation rec {
  name = "ewlc-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "Enerccio";
    repo = "ewlc";
    inherit rev;
    sha256 = "9255d4c4c287fff5dd424054f7378313d8a7b64c0ca7a5681bbf55727e8110b2";
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

  # Make libwlc compatible links
  postInstall = ''
    pushd "$out" >/dev/null
    for lib in $(find lib64 -name \*ewlc\*); do
      ln -sv "$(basename "$lib")" "$(echo "$lib" | sed 's,ewlc,wlc,g')"
    done
    popd >/dev/null
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
