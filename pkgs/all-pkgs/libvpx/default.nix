{stdenv
, fetchFromGitHub
, perl
, yasm

, vp8DecoderSupport ? true # VP8 decoder
, vp8EncoderSupport ? true # VP8 encoder
, vp9DecoderSupport ? true # VP9 decoder
, vp9EncoderSupport ? true # VP9 encoder
, extraWarningsSupport ? false # emit non-fatal warnings
, werrorSupport ? false # treat warnings as errors (not available with all compilers)
, debugSupport ? false # debug mode
, gprofSupport ? false # gprof profiling instrumentation
, gcovSupport ? false # gcov coverage instrumentation
, sizeLimitSupport ? true # limit max size to allow in the decoder
, optimizationsSupport ? true # compiler optimization flags
, runtimeCpuDetectSupport ? true # detect cpu capabilities at runtime
, thumbSupport ? false # build arm assembly in thumb mode
, examplesSupport ? true # build examples (vpxdec & vpxenc are part of examples)
, fastUnalignedSupport ? true # use unaligned accesses if supported by hardware
, debugLibsSupport ? false # include debug version of each library
, postprocSupport ? true # postprocessing
, multithreadSupport ? true # multithreaded decoding & encoding
, internalStatsSupport ? false # output of encoder internal stats for debug, if supported (encoders)
, memTrackerSupport ? false # track memory usage
, spatialResamplingSupport ? true # spatial sampling (scaling)
, realtimeOnlySupport ? false # build for real-time encoding
, ontheflyBitpackingSupport ? false # on-the-fly bitpacking in real-time encoding
, errorConcealmentSupport ? false # decoder conceals losses
, smallSupport ? false # favor smaller binary over speed
, postprocVisualizerSupport ? false # macro block/block level visualizers
, webmIOSupport ? true # input from and output to webm container
, libyuvSupport ? true # libyuv
, multiResEncodingSupport ? false # multiple-resolution encoding
, temporalDenoisingSupport ? true # use temporal denoising instead of spatial denoising
, coefficientRangeCheckingSupport ? false # decoder checks if intermediate transform coefficients are in valid range
, vp9HighbitdepthSupport ? true # 10/12 bit color support in VP9
, experimentalSupport ? false # experimental features
# Experimental features
, experimentalSpatialSvcSupport ? false # Spatial scalable video coding
, experimentalFpMbStatsSupport ? false
, experimentalEmulateHardwareSupport ? false
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    elem
    enFlag
    optional
    optionals
    platforms;
in

assert vp8DecoderSupport || vp8EncoderSupport || vp9DecoderSupport || vp9EncoderSupport;
assert internalStatsSupport && (vp9DecoderSupport || vp9EncoderSupport) -> postprocSupport;
/* If spatialResamplingSupport not enabled, build will fail with undeclared variable errors.
   Variables called in vpx_scale/generic/vpx_scale.c are declared by vpx_scale/vpx_scale_rtcd.pl,
   but is only executed if spatialResamplingSupport is enabled */
assert spatialResamplingSupport;
assert postprocVisualizerSupport -> postprocSupport;
assert vp9HighbitdepthSupport -> (vp9DecoderSupport || vp9EncoderSupport);

stdenv.mkDerivation rec {
  name = "libvpx-${version}";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "webmproject";
    repo = "libvpx";
    rev = "v${version}";
    sha256 = "f0c64c183973ac26c65dc53f12d83188609687943eb98ce663fe7997ec707b6d";
  };

  nativeBuildInputs = [
    perl
    yasm
  ];

  postPatch = ''
    patchShebangs .
  '';

  configureFlags = [
    (enFlag "vp8" (vp8EncoderSupport || vp8DecoderSupport) null)
    (enFlag "vp8-encoder" vp8EncoderSupport null)
    (enFlag "vp8-decoder" vp8DecoderSupport null)
    (enFlag "vp9" (vp9EncoderSupport || vp9DecoderSupport) null)
    (enFlag "vp9-encoder" vp9EncoderSupport null)
    (enFlag "vp9-decoder" vp9DecoderSupport null)
    (enFlag "extra-warnings" extraWarningsSupport null)
    (enFlag "werror" werrorSupport null)
    "--disable-install-docs"
    (enFlag "install-bins" examplesSupport null)
    "--enable-install-libs"
    "--disable-install-srcs"
    (enFlag "debug" debugSupport null)
    (enFlag "gprof" gprofSupport null)
    (enFlag "gcov" gcovSupport null)
    # Required to build shared libraries
    (enFlag "pic" true null)
    (enFlag "use-x86inc" true null)  # Fixme, we are always on x86 for now
    (enFlag "optimizations" optimizationsSupport null)
    (enFlag "runtime-cpu-detect" runtimeCpuDetectSupport null)
    (enFlag "thumb" thumbSupport null)
    "--enable-libs"
    (enFlag "examples" examplesSupport null)
    "--disable-docs"
    "--as=yasm"
    # Limit default decoder max to WHXGA
    (if sizeLimitSupport then "--size-limit=5120x3200" else null)
    #(enFlag fastUnalignedSupport "fast-unaligned" null)
    "--disable-codec-srcs"
    (enFlag "debug-libs" debugLibsSupport null)
    #(enFlag "dequant-tokens" isMips null)
    #(enFlag "dc-recon" isMips null)
    (enFlag "postproc" postprocSupport null)
    (enFlag "vp9-postproc" (
      postprocSupport
      && (vp9DecoderSupport || vp9EncoderSupport)) null)
    (enFlag "multithread" multithreadSupport null)
    (enFlag "internal-stats" internalStatsSupport null)
    #(enFlag "mem-tracker" memTrackerSupport null)
    (enFlag "spatial-resampling" spatialResamplingSupport null)
    (enFlag "realtime-only" realtimeOnlySupport null)
    (enFlag "onthefly-bitpacking" ontheflyBitpackingSupport null)
    (enFlag "error-concealment" errorConcealmentSupport null)
    # Shared libraries are only supported on ELF platforms
    "--disable-static --enable-shared"
    (enFlag "small" smallSupport null)
    (enFlag "postproc-visualizer" postprocVisualizerSupport null)
    (enFlag "unit-tests" false null)
    (enFlag "webm-io" webmIOSupport null)
    (enFlag "libyuv" libyuvSupport null)
    (enFlag "decode-perf-tests" false null)
    (enFlag "encode-perf-tests" false null)
    (enFlag "multi-res-encoding" multiResEncodingSupport null)
    (enFlag "temporal-denoising" temporalDenoisingSupport null)
    (enFlag "vp9-temporal-denoising" (
      temporalDenoisingSupport
      && (vp9DecoderSupport || vp9EncoderSupport)) null)
    (enFlag "coefficient-range-checking" coefficientRangeCheckingSupport null)
    (enFlag  "vp9-highbitdepth"(
      vp9HighbitdepthSupport
      && elem targetSystem platforms.bit64) null)
    (enFlag "experimental" (
      experimentalSpatialSvcSupport
      || experimentalFpMbStatsSupport
      || experimentalEmulateHardwareSupport) null)
    # Experimental features
  ] ++ optional experimentalSpatialSvcSupport "--enable-spatial-svc"
    ++ optional experimentalFpMbStatsSupport "--enable-fp-mb-stats"
    ++ optional experimentalEmulateHardwareSupport "--enable-emulate-hardware";

  meta = with stdenv.lib; {
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
