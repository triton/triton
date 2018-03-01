{ stdenv
, fetchurl

, bzip2
, libedit
, zlib
}:

let
  tarballUrls = version: [
    "https://ftp.pcre.org/pub/pcre/pcre2-${version}.tar.bz2"
    "http://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre2-${version}.tar.bz2"
    "mirror://sourceforge/pcre/pcre/${version}/pcre2-${version}.tar.bz2"
  ];

  version = "10.31";
in
stdenv.mkDerivation rec {
  name = "pcre2-${version}";

  src = fetchurl {
    url = tarballUrls version;
    hashOutput = false;
    sha256 = "e07d538704aa65e477b6a392b32ff9fc5edf75ab9a40ddfc876186c4ff4d68ac";
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

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "10.31";
      pgpsigUrls = map (n: "${n}.sig") urls;
        # Philip Hazel
      pgpKeyFingerprint = "45F6 8D54 BBE2 3FB3 039B  46E5 9766 E084 FB0F 43D8";
      inherit (src) outputHash outputHashAlgo;
    };
  };

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
