{ stdenv
, autoreconfHook
, fetchurl
, lib

, fftw_single
, speexdsp
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    boolEn
    elem
    platforms;
in
stdenv.mkDerivation rec {
  name = "speex-1.2rc2";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/speex/${name}.tar.gz";
    sha256 = "caa27c7247ff15c8521c2ae0ea21987c9e9710a8f2d3448e8b79da9806bce891";
  };

  postPatch = ''
    sed -i configure.ac \
      -e '/AC_CONFIG_MACRO_DIR/i PKG_PROG_PKG_CONFIG'
  '';

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    fftw_single
    speexdsp
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-valgrind"
    "--${boolEn (elem targetSystem platforms.x86-all)}-sse"
    "--disable-fixed-point"
    "--enable-float-api"
    "--enable-binaries"
    "--disable-vbr"
    "--disable-arm4-asm"
    "--disable-arm5e-asm"
    "--disable-blackfin-asm"
    "--disable-fixed-point-debug"
    "--disable-ti-c55x"
    "--disable-vorbis-psy"
    "--with-fft=gpl-fftw3"
  ];

  meta = with lib; {
    description = "An audio compression format designed for speech";
    hompage = http://www.speex.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
