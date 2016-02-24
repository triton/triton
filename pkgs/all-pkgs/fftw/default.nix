{ stdenv
, fetchurl
, precision
}:

assert stdenv.lib.elem precision [
  "single"
  "double"
  "long-double"
  "quad-precision"
];

let
  inherit (stdenv.lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "fftw-${precision}-${version}";
  version = "3.3.4";

  src = fetchurl {
    url = "ftp://ftp.fftw.org/pub/fftw/fftw-${version}.tar.gz";
    sha256 = "10h9mzjxnwlsjziah4lri85scc05rlajz39nqf3mbh4vja8dw34g";
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

  meta = with stdenv.lib; {
    description = "Fastest Fourier Transform in the West library";
    homepage = http://www.fftw.org/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
