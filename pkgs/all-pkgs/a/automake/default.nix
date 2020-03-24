{ stdenv
, autoconf
, fetchurl
, lib
, perl
}:

let
  version = "1.16.2";

  tarballUrls = version: [
    "mirror://gnu/automake/automake-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "automake-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "ccc459de3d710e066ab9e12d2f119bd164a08c9341ca24ba22c9adaa179eedd0";
  };

  buildInputs = [
    perl
    autoconf
  ];

  setupHook = ./setup-hook.sh;

  # We don't want NIX_STORE paths in our dist scripts like config.guess
  dontPatchShebangs = true;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.16.2";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprints = [
        # Mathieu Lirzin
        "F2A3 8D7E EB2B 6640 5761  070D 0ADE E100 9460 4D37"
      ];
      outputHash = "ccc459de3d710e066ab9e12d2f119bd164a08c9341ca24ba22c9adaa179eedd0";
      inherit (src) outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "GNU standard-compliant makefile generator";
    homepage = "http://www.gnu.org/software/automake/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux
      ++ i686-linux;
  };
}
