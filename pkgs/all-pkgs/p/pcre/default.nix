{ stdenv
, fetchTritonPatch
, fetchurl

, pcregrep ? false
  , bzip2 ? null
  , zlib ? null
}:

let
  inherit (stdenv.lib)
    enFlag
    optionals;
in

stdenv.mkDerivation rec {
  name = "pcre-8.39";

  src = fetchurl {
    url = "http://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${name}.tar.bz2";
    multihash = "QmPjEjowUiEi149yAUYcutkXvvxNmFGWuxkQZq6V4o1T7H";
    sha256 = "12wyajlqx2v7dsh39ra9v9m5hibjkrl129q90bp32c28haghjn5q";
  };

  patches = [
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
