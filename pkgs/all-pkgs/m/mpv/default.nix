{ stdenv
, fetchzip
, makeWrapper
, perl
, pkgconfig
, python
, waf
, which

, alsa-lib
, ffmpeg
, freefont_ttf
, freetype
, jack2_lib
, libass
, libbluray
, libbs2b
, libcaca
, libdvdnav
, libdvdread
, libpng
, libtheora
, libva
, libvdpau
#, lua
#, luaPackages
, pythonPackages
, mesa
, pulseaudio_lib
#, SDL2
, speex
, xorg
}:

let
  inherit (stdenv.lib)
    optional
    optionals
    optionalString;

  version = "0.21.0";
in
stdenv.mkDerivation rec {
  name = "mpv-${version}";

  src = fetchzip {
    version = 2;
    url = "https://github.com/mpv-player/mpv/archive/v${version}.tar.gz";
    sha256 = "5c5210de0d47cb2e34661cfb23b17f3dca8f9ffc86ed73f9d3e7143e32eea1d4";
  };

  nativeBuildInputs = [
    makeWrapper
    perl
    python
    pythonPackages.docutils
    waf
    which
  ];

  buildInputs = [
    alsa-lib
    ffmpeg
    freefont_ttf
    freetype
    jack2_lib
    libass
    libbluray
    libbs2b
    libcaca
    libdvdnav
    libdvdnav.libdvdread
    libdvdread
    libpng
    libtheora
    libva
    libvdpau
    # MPV does not support lua 5.3 yet
    #lua
    #luaPackages.luasocket
    mesa
    pulseaudio_lib
    pythonPackages.youtube-dl
    #SDL2
    speex
    xorg.libpthreadstubs
    xorg.libX11
    xorg.libXext
    xorg.libXinerama
    xorg.libXScrnSaver
    xorg.libXv
    xorg.libXxf86vm
  ];

  configureFlags = [
    "--enable-libmpv-shared"
    "--disable-libmpv-static"
    "--disable-static-build"
    "--enable-manpage-build"
    "--disable-build-date" # Purity
    "--enable-zsh-comp"
    "--enable-vaapi"
  ];

  postInstall = /* Use a standard font */ ''
    mkdir -pv $out/share/mpv
    ln -sv ${freefont_ttf}/share/fonts/truetype/FreeSans.ttf \
      $out/share/mpv/subfont.ttf
  '';

  preFixup =
    /* Ensure youtube-dl is available in $PATH for MPV */ ''
      wrapProgram $out/bin/mpv \
        --prefix PATH : "${pythonPackages.youtube-dl}/bin"
    '';

  meta = with stdenv.lib; {
    description = "A media player that supports many video formats";
    homepage = http://mpv.io;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
