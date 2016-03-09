{ stdenv
, fetchurl
, makeWrapper
, perl
, pkgconfig
, python
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
, SDL2
, speex
, xorg
}:

with {
  inherit (stdenv.lib)
    optional
    optionals
    optionalString;
};

let
  # Purity: Waf is normally downloaded by bootstrap.py, but
  # for purity reasons this behavior should be avoided.
  waf = fetchurl {
    url = http://ftp.waf.io/pub/release/waf-1.8.12;
    sha256 = "12y9c352zwliw0zk9jm2lhynsjcf5jy0k1qch1c1av8hnbm2pgq1";
  };
in

stdenv.mkDerivation rec {
  name = "mpv-${version}";
  version = "0.16.0";

  src = fetchurl {
    url = "https://github.com/mpv-player/mpv/archive/v${version}.tar.gz";
    sha256 = "1fiqxx85s418qynq2fp0v7cpzrz8j285hwmc4fqgn5ny1vg1jdpw";
  };

  nativeBuildInputs = [
    makeWrapper
    perl
    python
    pythonPackages.docutils
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
    SDL2
    speex
    xorg.libpthreadstubs
    xorg.libX11
    xorg.libXext
    xorg.libXinerama
    xorg.libXScrnSaver
    xorg.libXv
    xorg.libXxf86vm
  ];

  postPatch = ''
    patchShebangs ./TOOLS/
  '';

  configureFlags = [
    "--enable-libmpv-shared"
    "--disable-libmpv-static"
    "--disable-static-build"
    "--enable-manpage-build"
    "--disable-build-date" # Purity
    "--enable-zsh-comp"
    "--enable-vaapi"
  ];

  configurePhase = ''
    python ${waf} configure --prefix=$out $configureFlags
  '';

  buildPhase = ''
    python ${waf} build
  '';

  installPhase = ''
    python ${waf} install
  '' + /* Use a standard font */ ''
    mkdir -pv $out/share/mpv
    ln -sv ${freefont_ttf}/share/fonts/truetype/FreeSans.ttf $out/share/mpv/subfont.ttf
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
