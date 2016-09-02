{ stdenv
, fetchurl
, libsigsegv
, readline
}:

let
  version = "4.1.4";

  tarballUrls = version: [
    "mirror://gnu/gawk/gawk-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "gawk-${version}";

  src = fetchurl {
    url = tarballUrls version;
    hashOutput = false;
    sha256 = "53e184e2d0f90def9207860531802456322be091c7b48f23fdc79cda65adc266";
  };

  buildInputs = [
    libsigsegv
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
      urls = tarballUrls "4.1.4";
      outputHash = "53e184e2d0f90def9207860531802456322be091c7b48f23fdc79cda65adc266";
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
