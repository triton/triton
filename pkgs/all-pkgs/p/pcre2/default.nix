{ stdenv
, fetchurl

, bzip2
, libedit
, zlib
}:

stdenv.mkDerivation rec {
  name = "pcre2-10.23";

  src = fetchurl {
    url = "http://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${name}.tar.bz2";
    multihash = "QmTF83JjY7todppYY9MhgiVTEBcURbvTXa7PHAoiQHBua9";
    sha256 = "dfc79b918771f02d33968bd34a749ad7487fa1014aeb787fad29dd392b78c56e";
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
