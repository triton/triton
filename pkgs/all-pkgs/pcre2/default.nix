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
  name = "pcre2-10.21";

  src = fetchurl {
    url = "http://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${name}.tar.bz2";
    sha256 = "1q6lrj9b08l1q39vxipb0fi88x6ybvkr6439h8bjb9r8jd81fsn6";
  };

  buildInputs = optionals pcregrep [
    bzip2
    zlib
  ];

  configureFlags = [
    "--enable-pcre2-8"
    "--enable-pcre2-16"
    "--enable-pcre2-32"
    "--disable-debug"
    "--enable-jit"
    (enFlag "pcre2grep-jit" pcregrep null)
    "--enable-unicode"
    "--enable-stack-for-recursion"
    (enFlag "pcre2grep-libz" (pcregrep && zlib != null) null)
    (enFlag "pcre2grep-libbz2" (pcregrep && bzip2 != null) null)
    "--disable-pcre2test-libedit"
    "--disable-pcre2test-libreadline"
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
