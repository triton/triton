{ stdenv
, fetchurl

, pcregrep ? false
  , bzip2 ? null
  , zlib ? null
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals;
};

stdenv.mkDerivation rec {
  name = "pcre-8.38";

  src = fetchurl {
    url = "http://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${name}.tar.bz2";
    sha256 = "1pvra19ljkr5ky35y2iywjnsckrs9ch2anrf5b0dc91hw8v2vq5r";
  };

  configureFlags = [
    "--enable-pcre8"
    "--enable-pcre16"
    "--enable-pcre32"
    "--enable-cpp"
    "--enable-jit"
    (enFlag "pcregrep-jit" pcregrep null)
    "--enable-utf"
    "--enable-unicode-properties"
    (enFlag "pcregrep-libz" (pcregrep && zlib != null) null)
    (enFlag "pcregrep-libbz2" (pcregrep && bzip2 != null) null)
    "--disable-pcretest-libedit"
    "--disable-pcretest-libreadline"
    "--disable-valgrind"
    "--disable-coverage"
  ];

  buildInputs = optionals pcregrep [
    bzip2
    zlib
  ];

  outputs = [
    "out"
    "doc"
    "man"
  ];

  doCheck = true;
  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Perl Compatible Regular Expressions";
    homepage = "http://www.pcre.org/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
