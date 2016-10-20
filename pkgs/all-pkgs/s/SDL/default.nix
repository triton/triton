{ stdenv
, fetchurl
, lib

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
  version = "2.0.5";
in
stdenv.mkDerivation rec {
  name = "SDL-${version}";

  src = fetchurl {
    url = "https://www.libsdl.org/release/SDL2-${version}.tar.gz";
    hashOutput = false;
    sha256 = "442038cf55965969f2ff06d976031813de643af9c9edc9e331bd761c242e8785";
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

  meta = with lib; {
    description = "Simple Direct Media Layer";
    homepage = http://www.libsdl.org;
    license = licenses.zlib;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
