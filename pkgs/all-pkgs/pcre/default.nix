{ stdenv
, fetchTritonPatch
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

  patches = [
    (fetchTritonPatch {
      rev = "f595acad67433d7ac50f03c05b6e5d530b2cd78a";
      file = "pcre/CVE-2016-1283.patch";
      sha256 = "d133102d68c9f95aec3ff25afcc715294ee9a3e420e8a6529fac1b602fe2af36";
    })
    (fetchTritonPatch {
      rev = "f595acad67433d7ac50f03c05b6e5d530b2cd78a";
      file = "pcre/head-overflow-r1636.patch";
      sha256 = "7fda9e90001e46b5d47fc12ebf48ebb4389d6e80365677348015a62574024bd6";
    })
  ];

  buildInputs = optionals pcregrep [
    bzip2
    zlib
  ];

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

  outputs = [
    "out"
    "doc"
    "man"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Perl Compatible Regular Expressions";
    homepage = "http://www.pcre.org/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
