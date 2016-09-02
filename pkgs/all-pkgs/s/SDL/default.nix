{ stdenv
, fetchTritonPatch
, fetchurl

, alsa-lib
, dbus
, libxkbcommon
, mesa
, pulseaudio_lib
, systemd_lib
, wayland
, xorg
}:

let
  version = "2.0.4";
in
stdenv.mkDerivation rec {
  name = "SDL-${version}";

  src = fetchurl {
    url = "https://www.libsdl.org/release/SDL2-${version}.tar.gz";
    hashOutput = false;
    sha256 = "da55e540bf6331824153805d58b590a29c39d2d506c6d02fa409aedeab21174b";
  };

  buildInputs = [
    alsa-lib
    dbus
    libxkbcommon
    mesa
    pulseaudio_lib
    systemd_lib
    wayland
    xorg.fixesproto
    xorg.inputproto
    xorg.kbproto
    xorg.libICE
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXScrnSaver
    xorg.libXxf86vm
    xorg.scrnsaverproto
    xorg.xextproto
    xorg.xf86vidmodeproto
    xorg.xproto
  ];

  patches = [
    (fetchTritonPatch {
      rev = "8465dfdbd2609209e7c671ab789d5bbab3c26def";
      file = "SDL/fix-wayland.patch";
      sha256 = "79c477c164271a3a5c33490ffffa56c8cec59f1928214d65f0fd50d285e6278a";
    })
  ];

  # There is a build bug with `--disable-static`
  dontDisableStatic = true;

  postInstall = ''
    find $out/lib -name \*.a -delete
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "1528 635D 8053 A57F 77D1  E086 30A5 9377 A776 3BE6";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
