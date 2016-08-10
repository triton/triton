{ stdenv
, fetchurl

, libSDL
, xorg
}:

let
  inherit (stdenv.lib)
    enFlag
    optionals
    wtFlag;
in

assert xorg != null ->
  xorg.libICE != null
  && xorg.libSM != null
  && xorg.libXt != null
  && xorg.libXv != null;

stdenv.mkDerivation rec {
  version = "0.5.1";
  name = "libmpeg2-${version}";

  src = fetchurl {
    url = "http://libmpeg2.sourceforge.net/files/${name}.tar.gz";
    sha256 = "1m3i322n2fwgrvbs1yck7g5md1dbg22bhq5xdqmjpz5m7j4jxqny";
  };

  buildInputs = [
    libSDL
  ] ++ optionals (xorg != null) [
    xorg.libICE
    xorg.libSM
    xorg.libXt
    xorg.libXv
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--enable-largefile"
    #"--enable-accel-detect"
    "--disable-directx"
    (enFlag "sdl" (libSDL != null) null)
    "--disable-warnings"
    "--disable-gprof"
    (wtFlag "x" (xorg != null) null)
  ];

  meta = with stdenv.lib; {
    description = "Library for decoding mpeg-2 and mpeg-1 video streams";
    homepage = http://libmpeg2.sourceforge.net/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
