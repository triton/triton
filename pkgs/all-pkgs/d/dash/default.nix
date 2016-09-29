{ stdenv
, fetchTritonPatch
, fetchurl

, libedit
}:

let
  inherit (stdenv.lib)
    boolWt;

  version = "0.5.9.1";
in
stdenv.mkDerivation rec {
  name = "dash-${version}";

  src = fetchurl rec {
    url = "http://gondor.apana.org.au/~herbert/dash/files/"
      + "${name}.tar.gz";
    multihash = "QmW4FcN8vawARi5hB8jbCLHaQP6vfEj94EhTqHfKEZtVY2";
    sha256 = "5ecd5bea72a93ed10eb15a1be9951dd51b52e5da1d4a7ae020efd9826b49e659";
  };

  buildInputs = [
    libedit
  ];

  patches = [
    (fetchTritonPatch {
      rev = "2e96cc8e06eaf6ad9643acd1fdddb23aba7759ea";
      file = "dash/dash-0.5.8.1-eval-warnx.patch";
      sha256 = "13840812b0e03039c4061fac9bfd01106e53ce51e9bfb794c8c4015e6f3033e9";
    })
  ];

  postPatch = /* Fix the invalid sort */ ''
    sed -i  src/mkbuiltins \
      -e 's/LC_COLLATE=C/LC_ALL=C/g'
  '';

  configureFlags = [
    "--enable-fnmatch"
    /* Do not pass --enable-glob due to
       https://bugs.gentoo.org/show_bug.cgi?id=443552. */
    #"--enable-glob"
  	/* Autotools use $LINENO as a proxy for extended debug support
  	   (i.e. they're running bash), so disable it. */
    "--disable-lineno"
    "--${boolWt (libedit != null)}-libedit"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = map (n: "${n}.sha256sum") src.urls;
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "A POSIX-compliant implementation of /bin/sh";
    homepage = http://gondor.apana.org.au/~herbert/dash/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
