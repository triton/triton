{ stdenv
, autoreconfHook
, fetchgit
, fetchurl

, fixedPoint ? false

, channel
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    boolEn
    elem
    optionals
    platforms;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "opus-${source.version}";

  nativeBuildInputs = [ ]
    ++ optionals (channel == "head") [
      autoreconfHook
    ];

  src =
    if channel == "head" then
      fetchgit {
        version = source.fetchzipversion;
        url = "git://git.xiph.org/opus.git";
        inherit (source) rev sha256;
      }
    else
    fetchurl {
      url = "http://downloads.xiph.org/releases/opus/${name}.tar.gz";
      hashOutput = false;
      inherit (source) sha256;
    };

  configureFlags = [
    "--disable-maintainer-mode"
    "--${boolEn fixedPoint}-fixed-point"
    "--disable-fixed-point-debug"
    "--${boolEn (!fixedPoint)}-float-api"
    # non-Opus modes, e.g. 44.1 kHz & 2^n frames
    "--enable-custom-modes"
    # Requires IEEE 754 floating point
    "--enable-float-approx"
    "--enable-asm"
    "--enable-rtcd"
    # Enable intrinsics optimizations for ARM & X86
    "--${boolEn (
      (elem targetSystem platforms.arm-all)
      || (elem targetSystem platforms.x86-all))}-intrinsics"
    "--disable-assertions"
    "--disable-fuzzing"
    "--enable-ambisonics"
    "--disable-doc"
    "--disable-extra-programs"
    (if channel == "head" then "--enable-update-draft" else null)
    #--with-NE10
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
