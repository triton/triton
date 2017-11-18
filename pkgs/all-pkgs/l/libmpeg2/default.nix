{ stdenv
, fetchurl
, lib

, libice
, libsm
, libxt
, libxv
, sdl
}:

stdenv.mkDerivation rec {
  name = "libmpeg2-0.5.1";

  src = fetchurl {
    url = "http://libmpeg2.sourceforge.net/files/${name}.tar.gz";
    sha256 = "1m3i322n2fwgrvbs1yck7g5md1dbg22bhq5xdqmjpz5m7j4jxqny";
  };

  buildInputs = [
    libice
    libsm
    libxt
    libxv
    sdl
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--enable-largefile"
    #"--enable-accel-detect"
    "--disable-directx"
    "--enable-sdl"
    "--disable-warnings"
    "--disable-gprof"
    "--with-x"
  ];

  meta = with lib; {
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
