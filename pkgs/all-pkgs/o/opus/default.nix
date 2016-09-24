{ stdenv
, fetchurl

, fixedPoint ? false
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    boolEn;
in
stdenv.mkDerivation rec {
  name = "opus-1.1.3";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/opus/${name}.tar.gz";
    hashOutput = false;
    sha256 = "58b6fe802e7e30182e95d0cde890c0ace40b6f125cffc50635f0ad2eef69b633";
  };

  configureFlags = [
    "--disable-maintainer-mode"
    "--${boolEn fixedPoint}-fixed-point"
    "--${boolEn (!fixedPoint)}-float-api"
    # non-Opus modes, e.g. 44.1 kHz & 2^n frames
    "--enable-custom-modes"
    "--disable-float-approx"
    "--enable-asm"
    "--enable-rtcd"
    "--enable-intrinsics"
    "--disable-assertions"
    "--disable-fuzzing"
    "--enable-ambisonics"
    "--disable-doc"
    "--disable-extra-programs"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "http://downloads.xiph.org/releases/opus/SHA256SUMS.txt";
      failEarly = true;
    };
  };

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
