{ stdenv
, fetchFromGitHub
, perl
, yasm

, vp8DecoderSupport ? true # VP8 decoder
, vp8EncoderSupport ? true # VP8 encoder
, vp9DecoderSupport ? true # VP9 decoder
, vp9EncoderSupport ? true # VP9 encoder

, sizeLimitSupport ? true # limit max size to allow in the decoder
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
, coefficientRangeCheckingSupport ? false # decoder checks if intermediate transform coefficients are in valid range
, experimentalSupport ? false # experimental features
, betterHWCompatibility ? true
# Experimental features
, experimentalSpatialSvcSupport ? false # Spatial scalable video coding
, experimentalFpMbStatsSupport ? false
, experimentalEmulateHardwareSupport ? false
, experimentalMiscFixes ? false
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

assert vp8DecoderSupport
  || vp8EncoderSupport
  || vp9DecoderSupport
  || vp9EncoderSupport;
assert internalStatsSupport
  && (vp9DecoderSupport || vp9EncoderSupport) -> postprocSupport;
/* If spatialResamplingSupport not enabled, build will fail with
   undeclared variable errors. Variables called in
   vpx_scale/generic/vpx_scale.c are declared by vpx_scale/vpx_scale_rtcd.pl,
   but is only executed if spatialResamplingSupport is enabled */
assert spatialResamplingSupport;
assert postprocVisualizerSupport -> postprocSupport;

stdenv.mkDerivation rec {
  name = "libvpx-${version}";
  version = "1.6.0";

  src = fetchFromGitHub {
    version = 1;
    owner = "webmproject";
    repo = "libvpx";
    rev = "v${version}";
    sha256 = "54624ddcb3b1b18c867c1ed2ff1a726f7cfbd0fb6b2d87a5b24a9b60fd2f9478";
  };

  nativeBuildInputs = [
    perl
    yasm
  ];

  postPatch = ''
    patchShebangs ./build/make/rtcd.pl
  '';

  # Do NOT base configure flags on what is returned by --help, libvpx uses
  # FFmpeg's shell configure script and actual optionals are defined in
  # lists.  The help info is static and does not always represent all options.
  # See CMDLINE_SELECT in the configure script.
  configureFlags = [
    "--enable-dependency-tracking"
    #external_build
    "--enable-extra-warnings"
    "--disable-werror"
    "--disable-install-docs"
    (enFlag "install-bins" examplesSupport null)
    "--enable-install-libs"
    "--disable-install-srcs"
    "--disable-debug"
    "--disable-gprof"
    "--disable-gcov"
    # Required to build shared libraries
    "--enable-pic"
    (enFlag "use-x86inc" (elem targetSystem platforms.x86_64) null)
    "--enable-optimizations"
    "--disable-ccache"
    "--enable-runtime-cpu-detect"
    "--disable-thumb"
    "--enable-libs"
    (enFlag "examples" examplesSupport null)
    "--disable-docs"
    #libc
    "--as=yasm"
    # Limit default decoder max to WHXGA
    (if sizeLimitSupport then "--size-limit=5120x3200" else null)
    "--disable-codec-srcs"
    "--disable-debug-libs"
    (enFlag "dequant-tokens" (elem targetSystem platforms.mips) null)
    (enFlag "dc-recon" (elem targetSystem platforms.mips) null)
    (enFlag "postproc" postprocSupport null)
    (enFlag "vp9-postproc" (
      postprocSupport
      && (vp9DecoderSupport || vp9EncoderSupport)) null)
    (enFlag "multithread" multithreadSupport null)
    (enFlag "internal-stats" internalStatsSupport null)

    (enFlag "vp8" (vp8EncoderSupport || vp8DecoderSupport) null)
    (enFlag "vp8-encoder" vp8EncoderSupport null)
    (enFlag "vp8-decoder" vp8DecoderSupport null)
    (enFlag "vp9" (vp9EncoderSupport || vp9DecoderSupport) null)
    (enFlag "vp9-encoder" vp9EncoderSupport null)
    (enFlag "vp9-decoder" vp9DecoderSupport null)

    "--disable-static-msvcrt"
    (enFlag "spatial-resampling" spatialResamplingSupport null)
    (enFlag "realtime-only" realtimeOnlySupport null)
    (enFlag "onthefly-bitpacking" ontheflyBitpackingSupport null)
    (enFlag "error-concealment" errorConcealmentSupport null)
    # Shared libraries are only supported on ELF platforms
    "--enable-shared"
    "--disable-static"
    "--disable-small"
    (enFlag "postproc-visualizer" postprocVisualizerSupport null)
    #os_support
    "--disable-unit-tests"
    "--enable-webm-io"
    "--enable-libyuv"
    "--disable-decode-perf-tests"
    "--disable-encode-perf-tests"
    (enFlag "multi-res-encoding" multiResEncodingSupport null)
    (enFlag "temporal-denoising" temporalDenoisingSupport null)
    (enFlag "vp9-temporal-denoising" (
      temporalDenoisingSupport
      && (vp9DecoderSupport || vp9EncoderSupport)) null)
    (enFlag "coefficient-range-checking" coefficientRangeCheckingSupport null)
    (enFlag "better-hw-compatibility" betterHWCompatibility null)
    # FIXME: once armv7l support is dropped, enable explicitly
    (enFlag  "vp9-highbitdepth"(
      (vp9DecoderSupport || vp9EncoderSupport)
      && elem targetSystem platforms.bit64) null)
    (enFlag "experimental" (
      experimentalSpatialSvcSupport
      || experimentalFpMbStatsSupport
      || experimentalEmulateHardwareSupport) null)
  ] # Experimental features
    ++ optional experimentalSpatialSvcSupport "--enable-spatial-svc"
    ++ optional experimentalFpMbStatsSupport "--enable-fp-mb-stats"
    ++ optional experimentalEmulateHardwareSupport "--enable-emulate-hardware"
    ++ optional experimentalMiscFixes "--enable-misc-fixes";

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
