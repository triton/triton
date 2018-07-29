{ stdenv
, fetchurl
, lib

, precision
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    boolEn
    elem
    optionals
    platforms;

  version = "3.3.8";
in

assert elem precision [
  "single" # libfftw3f
  "double" # libfftw3
  "long-double" # libfftw3l
  "quad-precision" # libfftw3q
];

stdenv.mkDerivation rec {
  name = "fftw-${precision}-${version}";

  src = fetchurl rec {
    url = "http://www.fftw.org/fftw-${version}.tar.gz";
    multihash = "QmTWiByEtQ9DnuVnMESfnT6jgiGYRtuTy33xKY1FDQ8kXg";
    hashOutput = false;
    sha256 = "6113262f6e92c5bd474f2875fa1b01054c4ad5040f6b0da7c03c98821d9ae303";
  };

  configureFlags = [
    "--${boolEn (precision == "single")}-single"
    "--${boolEn (precision == "single")}-float"
    ###"--${boolEn (precision == "double")}-double"
    "--${boolEn (precision == "long-double")}-long-double"
    "--${boolEn (precision == "quad-precision")}-quad-precision"
    "--${boolEn (
      elem targetSystem platforms.x86-all
      && precision == "single")}-sse"
    "--${boolEn (
      elem targetSystem platforms.x86-all
      && (precision == "single" || precision == "double"))}-sse2"
    # Could be enabled when our minimum is sandy bridge
    "--disable-avx"
    # Could be enabled when our minimum is haswell
    "--disable-avx2"
    "--disable-avx512"
    "--disable-avx-128-fma"
    "--disable-kcvi"
    "--${boolEn (elem targetSystem platforms.powerpc-all)}-altivec"
    "--disable-vsx"
    "--${boolEn (elem targetSystem platforms.arm-all)}-neon"
    #--enable-armv8cyclecounter
    "--${boolEn (
      precision == "single"
      || precision == "double")}-generic-simd128"
    "--${boolEn (
      precision == "single"
      || precision == "double")}-generic-simd256"
    #--enable-mips-zbus-timer
    "--enable-fma"
    #"--${boolEn (
    #  mpi != null
    #  && (
    #    precision == "single"
    #    || precision == "double"
    #    || precision == "long-double"))}-mpi"  null)
    "--disable-fortran"
    "--enable-openmp"
    "--enable-threads"
    "--without-slow-timer"
    "--without-our-malloc"
    "--without-our-malloc16"
    "--without-g77-wrappers"
    "--without-combined-threads"
  ];

  # Since this is used in a lot of shared libraries we need fPIC
  NIX_CFLAGS_COMPILE = [
    "-fPIC"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      md5Url = map (n: "${n}.md5sum") src.urls;
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Library for Fast Discrete Fourier Transform";
    homepage = http://www.fftw.org/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
