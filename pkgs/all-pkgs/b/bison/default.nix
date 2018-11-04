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

  version = "3.2";
in
stdenv.mkDerivation rec {
  name = "bison-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "deec377b95aa72ec4e1a33fe2c938d2480749d740b5291a7cc1d77808d3710bf";
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
      urls = tarballUrls "3.2";
      inherit (src) outputHashAlgo;
      outputHash = "deec377b95aa72ec4e1a33fe2c938d2480749d740b5291a7cc1d77808d3710bf";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "7DF8 4374 B1EE 1F97 64BB  E25D 0DDC AA32 78D5 264E";
      };
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
