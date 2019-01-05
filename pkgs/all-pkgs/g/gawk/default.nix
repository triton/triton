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

  version = "4.2.1";

  tarballUrls = version: [
    "mirror://gnu/gawk/gawk-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "gawk-${type}-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "d1119785e746d46a8209d28b2de404a57f983aa48670f4e225531d3bdc175551";
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

  configureFlags = optionals (type == "full") [
    "--with-libsigsegv-prefix=${libsigsegv}"
    "--with-readline=${readline}"
  ];

  postInstall = ''
    rm -v $out/bin/gawk-*
  '';

  preFixup = optionalString (type != "full") ''
    rm -r "$out"/etc
    rm -r "$out"/share/{locale,info,man}
  '';

  allowedReferences = [
    "out"
  ] ++ stdenv.cc.runtimeLibcLibs
    ++ optionals (type == "full") [
    libsigsegv
    gmp
    mpfr
    readline
  ];

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src) outputHashAlgo;
      failEarly = true;
      urls = tarballUrls "4.2.1";
      outputHash = "d1119785e746d46a8209d28b2de404a57f983aa48670f4e225531d3bdc175551";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "D196 7C63 7887 1317 7D86  1ED7 DF59 7815 937E C0D2";
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
      i686-linux
      ++ x86_64-linux;
  };
}
