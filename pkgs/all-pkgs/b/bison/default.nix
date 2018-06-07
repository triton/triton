{ stdenv
, fetchurl
, lib
, m4
, perl
}:

let
  tarballUrls = version: [
    "mirror://gnu/bison/bison-${version}.tar.xz"
  ];

  version = "3.0.4";
in
stdenv.mkDerivation rec {
  name = "bison-${version}";

  src = fetchurl {
    url = "mirror://gnu/bison/${name}.tar.gz";
    hashOutput = false;
    sha256 = "b67fd2daae7a64b5ba862c66c07c1addb9e6b1b05c5f2049392cfd8a2172952e";
  };

  nativeBuildInputs = [
    m4
    perl
  ];

  # We need this for bison to work correctly when being
  # used during the build process
  propagatedBuildInputs = [
    m4
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "3.0.5";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "7DF8 4374 B1EE 1F97 64BB  E25D 0DDC AA32 78D5 264E";
      inherit (src) outputHashAlgo;
      outputHash = "075cef2e814642e30e10e8155e93022e4a91ca38a65aa1d5467d4e969f97f338";
    };
  };

  meta = with lib; {
    description = "Yacc-compatible parser generator";
    homepage = "http://www.gnu.org/software/bison/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
