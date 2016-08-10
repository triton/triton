{ stdenv
, fetchurl

, bzip2
, libedit
, zlib
}:

stdenv.mkDerivation rec {
  name = "pcre2-10.21";

  src = fetchurl {
    url = "http://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${name}.tar.bz2";
    multihash = "QmW9xCF2ypYLEThkjpds3h6VFJ2cY7znYGRFcHGNURP22G";
    sha256 = "1q6lrj9b08l1q39vxipb0fi88x6ybvkr6439h8bjb9r8jd81fsn6";
  };

  buildInputs = [
    bzip2
    libedit
    zlib
  ];

  configureFlags = [
    "--enable-pcre2-8"
    "--enable-pcre2-16"
    "--enable-pcre2-32"
    "--disable-debug"
    "--enable-jit"
    "--enable-pcre2grep-jit"
    "--enable-unicode"
    "--enable-stack-for-recursion"
    "--enable-pcre2grep-libz"
    "--enable-pcre2grep-libbz2"
    "--enable-pcre2test-libedit"
    "--disable-pcre2test-libreadline"
    "--disable-valgrind"
    "--disable-coverage"
  ];

  meta = with stdenv.lib; {
    description = "Perl Compatible Regular Expressions";
    homepage = "http://www.pcre.org/";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
