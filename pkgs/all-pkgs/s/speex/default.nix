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
  name = "speex-1.2.0";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/speex/${name}.tar.gz";
    multihash = "QmcFCHkLDs75eRoz1ibHcqkvrCfG2uE2pSyAEEqRzBptPB";
    sha256 = "eaae8af0ac742dc7d542c9439ac72f1f385ce838392dc849cae4536af9210094";
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
