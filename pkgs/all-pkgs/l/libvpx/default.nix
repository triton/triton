{ stdenv
, fetchFromGitHub
, fetchurl
, lib
, nasm
, perl
, yasm

# Limit default decoder max to WHXGA
, sizeLimit ? "5120x3200" # limit max size to allow in the decoder
, examplesSupport ? true # build examples (vpxdec & vpxenc are part of examples)
, postprocSupport ? true # postprocessing
, multithreadSupport ? true # multithreaded decoding & encoding
, internalStatsSupport ? false # output of encoder internal stats for debug, if supported (encoders)
, spatialResamplingSupport ? true # spatial sampling (scaling)
, realtimeOnlySupport ? false # build for real-time encoding
, ontheflyBitpackingSupport ? false # on-the-fly bitpacking in real-time encoding
, errorConcealmentSupport ? false # decoder conceals losses
, postprocVisualizerSupport ? false # macro block/block level visualizers
, multiResEncodingSupport ? false # multiple-resolution encoding
, temporalDenoisingSupport ? true # use temporal denoising instead of spatial denoising
, consistentRecodeSupport ? false
, coefficientRangeCheckingSupport ? false # decoder checks if intermediate transform coefficients are in valid range
, experimentalSupport ? false # experimental features
, betterHWCompatibility ? true
# Experimental features
, experimentalSpatialSvcSupport ? false # Spatial scalable video coding
, experimentalFpMbStatsSupport ? false
, experimentalEmulateHardwareSupport ? false
, experimentalNonGreedyMvSupport ? false
, experimentalMlVarPartitionSupport ? false
, experimentalMiscFixes ? false

, channel
}:

assert internalStatsSupport -> postprocSupport;
/* If spatialResamplingSupport not enabled, build will fail with
   undeclared variable errors. Variables called in
   vpx_scale/generic/vpx_scale.c are declared by vpx_scale/vpx_scale_rtcd.pl,
   but is only executed if spatialResamplingSupport is enabled */
assert spatialResamplingSupport;
assert postprocVisualizerSupport -> postprocSupport;

let
  inherit (builtins)
    compareVersions;
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    boolEn
    boolString
    elem
    optional
    optionals
    platforms
    versionAtLeast;

  sources = {
    # TODO: remove yasm in next release
    "1.6" = {
      version = "1.6.1";
      sha256 = "1c2c0c2a97fba9474943be34ee39337dee756780fc12870ba1dc68372586a819";
    };
    # Upstream did not create a release tarball
    "1.7" = {
      fetchzipversion = 6;
      version = "1.7.0";
      rev = "v1.7.0";
      sha256 = "041f332578e3e9ad150ff2c782293b3f191b79932d569fbeb9a1bfe394958955";
    };
    "1.8" = {
      fetchzipversion = 6;
      version = "1.8.0";
      rev = "v1.8.0";
      sha256 = "6440189b9fa807a3a6dfed13cd81a8b5890553407dd7b23b6643816d1874ace0";
    };
    # master
    "1.999" = {
      fetchzipversion = 6;
      version = "2019-02-14";
      rev = "a90944ce794986d8c0daab1449903909ba1956a7";
      sha256 = "6105b5dd27461da34d96fc0416530ee197140ac31f60f847f849e0f9eef065ac";
    };
  };
  source = sources."${channel}";

  reqMin = v: (compareVersions v channel != 1);
  reqMax = v: (compareVersions channel v != 1);

  # Deprecated flag
  deprFlag = deprVer: flag:
    if reqMax deprVer then
      flag
    else
      null;
  # Flag added in later versions
  newFlag = minVer: flag:
    if reqMin minVer then
      flag
    else
      null;
in
stdenv.mkDerivation rec {
  name = "libvpx-${source.version}";

  src =
    if versionAtLeast channel "1.7" then
      fetchFromGitHub {
        version = source.fetchzipversion;
        owner = "webmproject";
        repo = "libvpx";
        inherit (source) rev sha256;
      }
    else
      fetchurl {
        url = "https://storage.googleapis.com/downloads.webmproject.org/"
          + "releases/webm/${name}.tar.bz2";
        inherit (source) sha256;
      };

  nativeBuildInputs = [
    perl
  ] ++ (
    if versionAtLeast source.version "1.6.2" then [
      nasm
    ] else [
      yasm
    ]
  );

  postPatch = ''
    patchShebangs ./build/make/rtcd.pl
  '';

  # Do NOT base configure flags on what is returned by --help, libvpx
  # uses FFmpeg's shell configure script and actual optionals are
  # defined in lists.  The help info is static and does not always
  # represent current options. See CMDLINE_SELECT in the configure script.
  configureFlags = [
    "--enable-dependency-tracking"
    #external_build
    "--enable-extra-warnings"
    "--disable-werror"
    "--disable-install-docs"
    "--${boolEn examplesSupport}-install-bins"
    "--enable-install-libs"
    "--disable-install-srcs"
    "--disable-debug"
    "--disable-gprof"
    "--disable-gcov"
    # Required to build shared libraries
    "--enable-pic"
    "--enable-optimizations"
    "--disable-ccache"
    "--enable-runtime-cpu-detect"
    "--disable-thumb"
    "--enable-libs"
    "--${boolEn examplesSupport}-examples"
    "--disable-docs"
    #libc
    "--as=${if versionAtLeast source.version "1.6.2" then "nasm" else "yasm"}"
    "${if (sizeLimit != null) then "--size-limit=${sizeLimit}" else null}"
    "--disable-codec-srcs"
    "--disable-debug-libs"
    "--${boolEn (elem targetSystem platforms.mips)}-dequant-tokens"
    "--${boolEn (elem targetSystem platforms.mips)}-dc-recon"
    "--${boolEn postprocSupport}-postproc"
    "--${boolEn postprocSupport}-vp9-postproc"
    "--${boolEn multithreadSupport}-multithread"
    "--${boolEn internalStatsSupport}-internal-stats"

    (deprFlag "1.8" "--enable-vp8")
    (deprFlag "1.8" "--enable-vp8-encoder")
    (deprFlag "1.8" "--enable-vp8-decoder")
    "--enable-vp9"
    "--enable-vp9-encoder"
    "--enable-vp9-decoder"

    "--disable-static-msvcrt"
    "--${boolEn spatialResamplingSupport}-spatial-resampling"
    "--${boolEn realtimeOnlySupport}-realtime-only"
    "--${boolEn ontheflyBitpackingSupport}-onthefly-bitpacking"
    "--${boolEn errorConcealmentSupport}-error-concealment"
    # Shared libraries are only supported on ELF platforms
    "--enable-shared"
    "--disable-static"
    "--disable-small"
    "--${boolEn postprocVisualizerSupport}-postproc-visualizer"
    #os_support
    "--disable-unit-tests"
    "--enable-webm-io"
    "--enable-libyuv"
    "--disable-decode-perf-tests"
    "--disable-encode-perf-tests"
    "--${boolEn multiResEncodingSupport}-multi-res-encoding"
    "--${boolEn temporalDenoisingSupport}-temporal-denoising"
    "--${boolEn temporalDenoisingSupport}-vp9-temporal-denoising"
    (newFlag "1.8" "--${boolEn consistentRecodeSupport}-consistent-recode")
    "--${boolEn coefficientRangeCheckingSupport}-coefficient-range-checking"
    "--${boolEn betterHWCompatibility}-better-hw-compatibility"
    "--${boolEn (elem targetSystem platforms.bit64)}-vp9-highbitdepth"
    "--${boolEn (
      experimentalSpatialSvcSupport
      || experimentalFpMbStatsSupport
      || experimentalEmulateHardwareSupport)}-experimental"
  ] # Experimental features
    ++ optional experimentalSpatialSvcSupport "--enable-spatial-svc"  # Removed in 1.8.x
    ++ optional experimentalFpMbStatsSupport "--enable-fp-mb-stats"
    ++ optional experimentalEmulateHardwareSupport "--enable-emulate-hardware"
    ++ optional experimentalNonGreedyMvSupport "--enable-non-greedy-mv"
    ++ optional experimentalMlVarPartitionSupport "--enable-ml-var-partition"  # Removed in 1.9.x
    ++ optional experimentalMiscFixes "--enable-misc-fixes";

  meta = with lib; {
    description = "WebM VP8/VP9 codec SDK";
    homepage = http://www.webmproject.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
        codyopel
    ];
    platforms   = with platforms;
      x86_64-linux;
  };
}
