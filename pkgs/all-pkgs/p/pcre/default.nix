{ stdenv
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
  name = "pcre-8.40";

  src = fetchurl {
    url = "http://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${name}.tar.bz2";
    multihash = "Qmb1CRCYu75PaCTR1mRkU84gorUeBgUdC2yACSc4h93evH";
    sha256 = "00e27a29ead4267e3de8111fcaa59b132d0533cdfdbdddf4b0604279acbcf4f4";
  };

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
