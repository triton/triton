{ stdenv
, fetchTritonPatch
, fetchurl

, libedit
}:

let
  inherit (stdenv.lib)
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "dash-${version}";
  release-version = "0.5.9";
  patch-version = "0";
  version = "${release-version}.${patch-version}";

  src = fetchurl rec {
    url = "http://gondor.apana.org.au/~herbert/dash/files/"
        + "dash-${release-version}.tar.gz";
    sha256Url = "${url}.sha256sum";
    sha256 = "92793b14c017d79297001556389442aeb9e3c1cc559fd178c979169b1a47629c";
  };

  buildInputs = [
    libedit
  ];

  patches = [
    # http://debian.mirrors.pair.com/debian/pool/main/d/dash/
    /*(fetchurl {
      url = "mirror://debian/pool/main/d/dash/"
          + "dash_${release-version}-${patch-version}.diff.gz";
      sha256 = "fc7e390aec750c270ffc15a77ba861da3c931f323b2463130e1114ff47c6732b";
    })*/
    (fetchTritonPatch {
      rev = "2e96cc8e06eaf6ad9643acd1fdddb23aba7759ea";
      file = "dash/dash-0.5.8.1-eval-warnx.patch";
      sha256 = "13840812b0e03039c4061fac9bfd01106e53ce51e9bfb794c8c4015e6f3033e9";
    })
  ];

  postPatch =
    /* Fix the invalid sort */ ''
      sed -i  src/mkbuiltins \
        -e 's/LC_COLLATE=C/LC_ALL=C/g'
    '';

  configureFlags = [
    "--enable-fnmatch"
    # Do not pass --enable-glob due to
    # https://bugs.gentoo.org/show_bug.cgi?id=443552.
    #"--enable-glob"
  	# Autotools use $LINENO as a proxy for extended debug support
  	# (i.e. they're running bash), so disable it.
    "--disable-lineno"
    (wtFlag "libedit" (libedit != null) null)
  ];

  meta = with stdenv.lib; {
    description = "A POSIX-compliant implementation of /bin/sh";
    homepage = http://gondor.apana.org.au/~herbert/dash/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
