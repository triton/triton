{ stdenv
, fetchurl

, bzip2
, libedit
, pcre2_lib
, zlib
}:

stdenv.mkDerivation rec {
  name = "pcre2-${pcre2_lib.version}";

  src = pcre2_lib.src;

  buildInputs = [
    bzip2
    libedit
    pcre2_lib
    zlib
  ];

  configureFlags = pcre2_lib.configureFlags ++ [
    "--enable-pcre2grep-jit"
    "--enable-pcre2grep-libz"
    "--enable-pcre2grep-libbz2"
    "--enable-pcre2test-libedit"
    "--disable-pcre2test-libreadline"
  ];

  NIX_LDFLAGS = "-rpath ${pcre2_lib}/lib";

  postInstall = ''
    rm -r "$out"/{bin/pcre2-config,include,lib}
  '';

  passthru = {
    inherit (pcre2_lib)
      version
      srcVerification;
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
