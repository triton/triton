{ stdenv
, fetchurl

, precision
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    elem
    enFlag
    optionals
    platforms;

  version = "3.3.5";
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
    md5Url = url + ".md5sum";
    sha256 = "8ecfe1b04732ec3f5b7d279fdb8efcad536d555f9d1e8fabd027037d45ea8bcf";
  };

  configureFlags = [
    (enFlag "single" (precision == "single") null)
    (enFlag "float" (precision == "single") null)
    ###(enFlag "double" (precision == "double") null)
    (enFlag "long-double" (precision == "long-double") null)
    (enFlag "quad-precision" (precision == "quad-precision") null)
    (enFlag "sse" (
      elem targetSystem platforms.x86-all
      && precision == "single") null)
    (enFlag "sse2" (
      elem targetSystem platforms.x86-all
      && (precision == "single" || precision == "double")) null)
    # Could be enabled when our minimum is sandy bridge
    "--disable-avx"
    # Could be enabled when our minimum is haswell
    "--disable-avx2"
    "--disable-avx512"
    "--disable-avx-128-fma"
    "--disable-kcvi"
    (enFlag "altivec" (elem targetSystem platforms.powerpc-all) null)
    "--disable-vsx"
    (enFlag "neon" (elem targetSystem platforms.arm-all) null)
    #--enable-armv8cyclecounter
    (enFlag "generic-simd128" (
      precision == "single"
      || precision == "double") null)
    (enFlag "generic-simd256" (
      precision == "single"
      || precision == "double") null)
    #--enable-mips-zbus-timer
    "--enable-fma"
    #(enFlag "mpi" (
    #  mpi != null
    #  && (
    #    precision == "single"
    #    || precision == "double"
    #    || precision == "long-double")) null)
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

  meta = with stdenv.lib; {
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
