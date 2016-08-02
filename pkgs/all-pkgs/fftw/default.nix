{ stdenv
, fetchurl
, precision
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "3.3.5";
in

assert stdenv.lib.elem precision [
  "single"
  "double"
  "long-double"
  "quad-precision"
];

stdenv.mkDerivation rec {
  name = "fftw-${precision}-${version}";

  src = fetchurl rec {
    url = "http://www.fftw.org/fftw-${version}.tar.gz";
    md5Url = url + ".md5sum";
    sha256 = "8ecfe1b04732ec3f5b7d279fdb8efcad536d555f9d1e8fabd027037d45ea8bcf";
  };

  configureFlags = [
    "--enable-fma"
  ] ++ optionals (precision != "double") [
    "--enable-${precision}"
  ] ++ optionals (precision == "single") [
    "--enable-sse"
    # "--enable-altivec"
    # "--enable-neon"  # Could be enabled on arm
  ] ++ optionals (precision == "single" || precision == "double") [
    "--enable-sse2"
    # "--enable-avx"  # Could be enabled when our minimum is sandy bridge
  ] ++ [
    "--disable-fortran"
    "--enable-openmp"
    "--enable-threads"
  ];

  # Since this is used in a lot of shared libraries we need fPIC
  NIX_CFLAGS_COMPILE = [
    "-fPIC"
  ];

  meta = with stdenv.lib; {
    description = "Fastest Fourier Transform in the West library";
    homepage = http://www.fftw.org/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
