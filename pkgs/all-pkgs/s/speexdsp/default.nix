{ stdenv
, autoreconfHook
, fetchFromGitHub
, fetchTritonPatch
, lib

, fftw_single
}:

let
  inherit (stdenv)
    targetSystem;

  inherit (stdenv.lib)
    boolEn
    elem
    platforms;
in
stdenv.mkDerivation rec {
  name = "speexdsp-2017-08-08";

  src = fetchFromGitHub {
    version = 5;
    owner = "xiph";
    repo = "speexdsp";
    # Upstream has not tagged a release since 2014
    rev = "85e8ad5432eb9333f727e7b18c97995317eabf02";
    sha256 = "5bfd04cffc5c855abebb042e5882bda8cf9b38cf90eb580328c34c7e1ea4052c";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    fftw_single
  ];

  patches = [
    (fetchTritonPatch {
      rev = "a09b4c47302a90468ea1ebea1f2537046230f572";
      file = "s/speexdsp/speex-1.2-fix-missing-fftw-libs.patch";
      sha256 = "0281a7b244f4301a7c3c9c4f175e5b55ad55f77e152435a96ede954ac71e7dda";
    })
  ];

  postPatch = /* Fix missing header */ ''
    sed -i ./include/speex/speexdsp_config_types.h.in \
      -e '3i#include <stdint.h>'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-valgrind"
    "--${boolEn (elem targetSystem platforms.x86-all)}-sse"
    "--disable-fixed-point"
    "--enable-float-api"
    "--disable-examples"
    "--disable-arm4-asm"
    "--disable-arm5e-asm"
    "--disable-blackfin-asm"
    "--disable-fixed-point-debug"
    "--disable-resample-full-sinc-table"
    "--disable-ti-c55x"
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
