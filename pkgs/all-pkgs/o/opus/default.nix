{ stdenv
, autoreconfHook
, fetchgit
, fetchurl
, lib

, fixedPoint ? false

, channel
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    boolEn
    elem
    optionals
    platforms;

  releaseUrls = [
    "https://archive.mozilla.org/pub/opus"
    "mirror://xiph/opus"
  ];

  sources = {
    "stable" = {
      version = "1.2.1";
      multihash = "QmT3msAH9XUDrWe43kP9Mpw47y6tmKBTrXmudNhXpKTji3";
      sha256 = "cfafd339ccd9c5ef8d6ab15d7e1a412c054bf4cb4ecbbbcc78c12ef2def70732";
    };
    "head" = {
      fetchzipversion = 3;
      version = "2017-06-20";
      rev = "acfa035bf7b5bbe68351c4a3bb41239ea882ff71";
      sha256 = "db061d88e28a3699805de0da69cbd5d2a5b78f45497d1b42485e698db4801f24";
    };
  };
  source = sources."${channel}";
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
        urls = map (n: "${n}/${name}.tar.gz") releaseUrls;
        hashOutput = false;
        inherit (source)
          multihash
          sha256;
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
    "--enable-update-draft"
    #--with-NE10
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      md5Urls = map (n: "${n}/MD5SUMS") releaseUrls;
      sha1Urls = map (n: "${n}/SHA1SUMS") releaseUrls;
      sha256Urls = map (n: "${n}/SHA256SUMS.txt") releaseUrls;
      failEarly = true;
    };
  };

  meta = with lib; {
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
