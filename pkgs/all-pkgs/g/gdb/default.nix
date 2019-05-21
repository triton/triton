{ stdenv
, fetchurl
, perl
, texinfo

, babeltrace
, expat
, gmp
, mpfr
, ncurses
, readline
, processor-trace
, python3
, xz
, zlib
}:

stdenv.mkDerivation rec {
  name = "gdb-8.3";

  src = fetchurl {
    url = "mirror://gnu/gdb/${name}.tar.xz";
    hashOutput = false;
    sha256 = "802f7ee309dcc547d65a68d61ebd6526762d26c3051f52caebe2189ac1ffd72e";
  };

  nativeBuildInputs = [
    perl
    texinfo
  ];

  buildInputs = [
    babeltrace
    expat
    gmp
    mpfr
    ncurses
    readline
    processor-trace
    python3
    xz
    zlib
  ];

  configureFlags = [
    "--with-system-zlib"
    "--with-system-readline"
    "--with-python=${python3.interpreter}"
    "--with-mpfr=${mpfr}"
  ];

  # The install junks up lib / include with some static library
  # files from the build. We don't want these.
  postInstall = ''
    rm -r "$out"/{include,lib}
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "F40A DB90 2B24 264A A42E  50BF 92ED B04B FF32 5CF3";
      };
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
