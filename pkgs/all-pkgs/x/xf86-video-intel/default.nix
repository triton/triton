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
  rev = "359477215092ac1b602ad1e2f17a28963d9224c2";
  date = "2018-05-12";
in
stdenv.mkDerivation {
  name = "xf86-video-intel-${date}";

  src = fetchFromGitLab {
    version = 6;
    host = "https://gitlab.freedesktop.org";
    owner = "xorg/driver";
    repo = "xf86-video-intel";
    inherit rev;
    sha256 = "93a59062b74697e930934bc0af73bf6edac43b5ba6fa39bf7c2bcc5687f8bb35";
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
