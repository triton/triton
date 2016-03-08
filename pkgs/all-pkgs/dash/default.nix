{ stdenv
, fetchTritonPatch
, fetchurl

, libedit
}:

with {
  inherit (stdenv.lib)
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "dash-${version}";
  release-version = "0.5.8";
  patch-version = "2.1";
  version = "${release-version}.${patch-version}";

  src = fetchurl {
    url = "http://gondor.apana.org.au/~herbert/dash/files/"
        + "dash-${release-version}.tar.gz";
    sha256 = "03y6z8akj72swa6f42h2dhq3p09xasbi6xia70h2vc27fwikmny6";
  };

  buildInputs = [
    libedit
  ];

  patches = [
    # http://debian.mirrors.pair.com/debian/pool/main/d/dash/
    (fetchurl {
      url = "mirror://debian/pool/main/d/dash/"
          + "dash_${release-version}-${patch-version}.diff.gz";
      sha256 = "1nm3bajpyv737j0b15hzhckg28hzwjiryhvgvhfp84bbin07nn4y";
    })
    (fetchTritonPatch {
      rev = "2e96cc8e06eaf6ad9643acd1fdddb23aba7759ea";
      file = "dash/dash-0.5.5.1-octal.patch";
      sha256 = "06741af243014a22ba1b530a5d4e4abd70b944dcb16f9e1ed86290745ff3dbd0";
    })
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
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
