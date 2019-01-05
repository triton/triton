{ stdenv
, bison
, fetchurl
, gnum4
}:

let
  tarballUrls = version: [
    "https://github.com/westes/flex/releases/download/v${version}/flex-${version}.tar.gz"
  ];

  version = "2.6.4";
in
stdenv.mkDerivation rec {
  name = "flex-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995";
  };

  nativeBuildInputs = [
    bison
    gnum4
  ];

  # Using static libraries fixes issues with references to
  # yylex in flex 2.6.0
  # This can be tested by building glusterfs
  configureFlags = [
    "--disable-shared"
  ];

  disableStatic = false;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.6.4";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "56C6 7868 E933 90AA 1039  AD1C E4B2 9C8D 6488 5307";
      inherit (src) outputHashAlgo;
      outputHash = "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995";
    };
  };

  meta = with stdenv.lib; {
    description = "A fast lexical analyser generator";
    homepage = http://flex.sourceforge.net/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
