{ stdenv
, fetchurl
, fetchpatch

, alsa-lib
, audiofile
, libcap
, mesa
, pulseaudio_lib
, xorg
}:

let
  inherit (stdenv.lib)
    optional
    optionals;
in
stdenv.mkDerivation rec {
  version = "1.2.15";
  name    = "SDL-${version}";

  src = fetchurl {
    url    = "http://www.libsdl.org/release/${name}.tar.gz";
    sha256 = "005d993xcac8236fpvd1iawkz4wqjybkpn8dbwaliqz5jfkidlyn";
  };

  buildInputs = [
    alsa-lib
    audiofile
    libcap
    mesa
    pulseaudio_lib
    xorg.randrproto
    xorg.renderproto
    xorg.libICE
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXrandr
    xorg.xextproto
    xorg.xproto
  ];

  # XXX: By default, SDL wants to dlopen() PulseAudio, in which case
  # we must arrange to add it to its RPATH; however, `patchelf' seems
  # to fail at doing this, hence `--disable-pulseaudio-shared'.
  configureFlags = [
    "--disable-oss"
    "--disable-video-x11-xme"
    "--disable-x11-shared"
    "--disable-alsa-shared"
    "--enable-rpath"
    "--disable-pulseaudio-shared"
    "--disable-osmesa-shared"
    "--with-alsa-prefix=${alsa-lib}/lib"
  ];

  patches = [
    # Fix window resizing issues, e.g. for xmonad
    # Ticket: http://bugzilla.libsdl.org/show_bug.cgi?id=1430
    (fetchpatch {
      name = "fix_window_resizing.diff";
      url = "https://bugs.debian.org/cgi-bin/bugreport.cgi?msg=10;filename=fix_window_resizing.diff;att=2;bug=665779";
      sha256 = "a96e0d86e47388a7b4166bcd93f11a52952d4e1fede164c4c4431698cfd68f7e";
    })
    # Fix drops of keyboard events for SDL_EnableUNICODE
    (fetchpatch {
      url = "https://hg.libsdl.org/SDL/raw-rev/0aade9c0203f";
      sha256 = "4a6f7c2a10bcbf4170ecfb2c05759a40f1a2da25a2e2c242d78f02cf14feace4";
    })
    # Ignore insane joystick axis events
    (fetchpatch {
      url = "https://hg.libsdl.org/SDL/raw-rev/95abff7adcc2";
      sha256 = "7fd95da12539c7ecd467c4dff56e2729dbd223c2f6708b9ba952710bf6f9c6e7";
    })
    # Workaround X11 bug to allow changing gamma
    # Ticket: https://bugs.freedesktop.org/show_bug.cgi?id=27222
    (fetchpatch {
      url = "http://pkgs.fedoraproject.org/cgit/rpms/SDL.git/plain/SDL-1.2.15-x11-Bypass-SetGammaRamp-when-changing-gamma.patch?id=04a3a7b1bd88c2d5502292fad27e0e02d084698d";
      sha256 = "df238d51889a722c5a51469bd545ec05e51fc130db1df0ea61526e801c9ab6f7";
    })
    # Fix a build failure on OS X Mavericks
    # Ticket: https://bugzilla.libsdl.org/show_bug.cgi?id=2085
    (fetchpatch {
      url = "https://hg.libsdl.org/SDL/raw-rev/e9466ead70e5";
      sha256 = "2d6be18730e013ec3ebf3088f5bb8289a837dc3d7b11b14a1fa737d4710cd26c";
    })
    (fetchpatch {
      url = "https://hg.libsdl.org/SDL/raw-rev/bbfb41c13a87";
      sha256 = "45a554b10913960364da1724c28dd8355afaaa3248a2d33664d5d7e28220f3a5";
    })
  ];

  meta = with stdenv.lib; {
    description = "A cross-platform multimedia library";
    homepage    = http://www.libsdl.org/;
    maintainers = with maintainers; [ lovek323 ];
    platforms   = platforms.all;
    license     = licenses.lgpl21;
  };
}
