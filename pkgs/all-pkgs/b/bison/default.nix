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

  version = "3.1";
in
stdenv.mkDerivation rec {
  name = "bison-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "7c2464ad6cb7b513b2c350a092d919327e1f63d12ff024836acbb504475da5c6";
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
      urls = tarballUrls "3.1";
      inherit (src) outputHashAlgo;
      outputHash = "7c2464ad6cb7b513b2c350a092d919327e1f63d12ff024836acbb504475da5c6";
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
