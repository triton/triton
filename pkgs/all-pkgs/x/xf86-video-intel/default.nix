{ stdenv
, fetchFromGitLab
, lib
, meson
, ninja

, libdrm
, libpciaccess
, libpng
, libx11
, libxcb
, libxcursor
, libxdamage
, libxext
, libxfixes
, libxfont2
, libxinerama
, libxrandr
, libxrender
, libxscrnsaver
, libxtst
, opengl-dummy
, systemd_lib
, xorgproto
, xorg-server
, xorg
}:

let
  rev = "33ee0c3b21ea279e08d0863fcb2e874f0974b00e";
  date = "2019-01-21";
in
stdenv.mkDerivation {
  name = "xf86-video-intel-${date}";

  src = fetchFromGitLab {
    version = 6;
    host = "https://gitlab.freedesktop.org";
    owner = "xorg/driver";
    repo = "xf86-video-intel";
    inherit rev;
    multihash = "Qmesq65GyAJXX863hFzTTgte2jyFzGBhW5BDVZcav2GpQc";
    sha256 = "0b6813e37b80977cc03490b11c076278261c68483b505ef17edc4f285a22964e";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    libdrm
    libpciaccess
    libpng
    libx11
    libxcb
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxfont2
    libxinerama
    libxrandr
    libxrender
    libxscrnsaver
    libxtst
    opengl-dummy
    xorg.libXvMC
    xorg.libXxf86vm
    xorg.pixman
    systemd_lib
    xorg.xcbutil
    xorgproto
    xorg-server
  ];

  mesonFlags = [
    "-Dvalgrind=false"
    "-Dtearfree=true"
  ];

  bindnow = false;

  meta = with lib; {
    description = "Intel video driver";
    homepage = https://cgit.freedesktop.org/xorg/driver/xf86-video-intel/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
