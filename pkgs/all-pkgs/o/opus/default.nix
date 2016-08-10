{ stdenv
, fetchurl

, fixedPoint ? false
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    elem
    enFlag
    platforms;
in

stdenv.mkDerivation rec {
  name = "opus-${version}";
  version = "1.1.3";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/opus/opus-${version}.tar.gz";
    sha256Url = "http://downloads.xiph.org/releases/opus/SHA256SUMS.txt";
    sha256 = "58b6fe802e7e30182e95d0cde890c0ace40b6f125cffc50635f0ad2eef69b633";
  };

  configureFlags = [
    "--disable-maintainer-mode"
    (enFlag "fixed-point" fixedPoint null)
    (enFlag "float-api" (!fixedPoint) null)
    # non-Opus modes, e.g. 44.1 kHz & 2^n frames
    "--enable-custom-modes"
    "--disable-float-approx"
    "--enable-asm"
    "--enable-rtcd"
    # Enable intrinsics optimizations for ARM(float) X86(fixed)
    (enFlag "intrinsics" (
      (elem targetSystem platforms.arm-all && !fixedPoint)
      || (elem targetSystem platforms.x86-all && fixedPoint)) null)
    "--disable-assertions"
    "--disable-fuzzing"
    "--enable-ambisonics"
    "--disable-doc"
    "--disable-extra-programs"
  ];

  meta = with stdenv.lib; {
    description = "Versatile codec designed for speech and audio transmission";
    homepage = http://www.opus-codec.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
