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
#, SDL2
, speex
, xorg
}:

let
  inherit (stdenv.lib)
    optional
    optionals
    optionalString;
in

let
  # Purity: Waf is normally downloaded by bootstrap.py, but
  # for purity reasons this behavior should be avoided.
  # FIXME: use waf package
  waf = fetchurl {
    url = https://waf.io/waf-1.8.21;
    sha256 = "31383a18d183c72be70d251e09b47389a6eb4bebbc94b737cff3187ddd88dff1";
  };
in

stdenv.mkDerivation rec {
  name = "mpv-${version}";
  version = "0.18.1";

  src = fetchurl {
    url = "https://github.com/mpv-player/mpv/archive/v${version}.tar.gz";
    sha256 = "e413d57fec4ad43b9f9b848f38d13fb921313fc9a4a64bf1e906c8d0f7a46329";
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
