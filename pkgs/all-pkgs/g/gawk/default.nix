{ stdenv
, fetchurl

, gmp
, libsigsegv
, mpfr
, readline
}:

let
  version = "4.2.0";

  tarballUrls = version: [
    "mirror://gnu/gawk/gawk-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "gawk-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "d4f3cd31c001fd0ed52832d4fbfbdfeaa38ad541c182f80ff8fdf87324a6a9f2";
  };

  buildInputs = [
    gmp
    libsigsegv
    mpfr
    readline
  ];

  configureFlags = [
    "--with-libsigsegv-prefix=${libsigsegv}"
    "--with-readline=${readline}"
  ];

  postInstall = ''
    rm -v $out/bin/gawk-*
  '';

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src) outputHashAlgo;
      failEarly = true;
      urls = tarballUrls "4.2.0";
      outputHash = "d4f3cd31c001fd0ed52832d4fbfbdfeaa38ad541c182f80ff8fdf87324a6a9f2";
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
