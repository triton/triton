{ stdenv
, fetchurl

, gmp
, libsigsegv
, mpfr
, readline

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;

  version = "5.0.1";

  tarballUrls = version: [
    "mirror://gnu/gawk/gawk-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "gawk-${type}-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "8e4e86f04ed789648b66f757329743a0d6dfb5294c3b91b756a474f1ce05a794";
  };

  # Small build doesn't need floating point with gmp / mpfr
  # Small build doesn't need libsigsegv output on crash
  # Small build doesn't need readline since it's only used in non-interactive
  buildInputs = optionals (type == "full") [
    libsigsegv
    gmp
    mpfr
    readline
  ];

  preConfigure = ''
    makeFlagsArray+=("AR=$AR")
  '';

  configureFlags = optionals (type == "full") [
    "--with-libsigsegv-prefix=${libsigsegv}"
    "--with-readline=${readline}"
  ];

  postInstall = ''
    rm -v "$bin"/bin/gawk-*
  '';

  postFixup = ''
    rm -rv "$bin"/{include,share}
  '' + optionalString (type != "full") ''
    rm -rv "$bin"/etc
  '';

  outputs = [
    "bin"
  ] ++ optionals (type == "full") [
    "man"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src) outputHashAlgo;
      failEarly = true;
      urls = tarballUrls "5.0.1";
      outputHash = "8e4e86f04ed789648b66f757329743a0d6dfb5294c3b91b756a474f1ce05a794";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "D196 7C63 7887 1317 7D86  1ED7 DF59 7815 937E C0D2";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "GNU implementation of the Awk programming language";
    homepage = http://www.gnu.org/software/gawk/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
