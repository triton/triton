{ stdenv
, autoreconfHook
, fetchFromGitHub
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
      version = "1.3";
      multihash = "QmZ26cTAXDkHJhj1ABJoUUUh1TN7SmzYQpuqenzTukAo9x";
      sha256 = "4f3d69aefdf2dbaf9825408e452a8a414ffc60494c70633560700398820dc550";
    };
    "head" = {
      fetchzipversion = 5;
      version = "2018-02-20";
      rev = "475fa4a98c7f4be57e507f55a37ef3fce79692a6";
      sha256 = "d9c191979a17264df62c4c61e8da7af153de6e8acbc64ba43bc2e9dfaf658ad9";
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
      fetchFromGitHub {
        version = source.fetchzipversion;
        owner = "xiph";
        repo = "opus";
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
    "--${boolEn (!fixedPoint)}-float-api"
    # non-Opus modes, e.g. 44.1 kHz & 2^n frames
    "--enable-custom-modes"
    "--enable-float-approx"
    "--disable-doc"
    "--disable-extra-programs"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      fullOpts = {
        md5Urls = map (n: "${n}/MD5SUMS") releaseUrls;
        sha1Urls = map (n: "${n}/SHA1SUMS") releaseUrls;
        sha256Urls = map (n: "${n}/SHA256SUMS.txt") releaseUrls;
      };
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
