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
      fetchzipversion = 6;
      version = "2019-01-23";
      rev = "9f2a0c70d40442f3f05a575c4ea3e9eb1051a195";
      sha256 = "d53946c96b7e341bf4260a34feb4f84e205a55498850c2a5adb9ce1b79dc6262";
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
