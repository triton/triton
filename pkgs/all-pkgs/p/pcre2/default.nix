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

  version = "10.30";
in
stdenv.mkDerivation rec {
  name = "pcre2-${version}";

  src = fetchurl {
    url = tarballUrls version;
    hashOutput = false;
    sha256 = "90bd41c605d30e3745771eb81928d779f158081a51b2f314bbcc1f73de5773db";
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
      urls = tarballUrls "10.30";
      pgpsigUrls = map (n: "${n}.sig") urls;
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
