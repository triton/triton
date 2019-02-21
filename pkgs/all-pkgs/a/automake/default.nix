{ stdenv
, autoconf
, fetchurl
, lib
, perl
}:

let
  version = "1.16.1";

  tarballUrls = version: [
    "mirror://gnu/automake/automake-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "automake-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "5d05bb38a23fd3312b10aea93840feec685bdf4a41146e78882848165d3ae921";
  };

  buildInputs = [
    perl
    autoconf
  ];

  setupHook = ./setup-hook.sh;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.16.1";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprints = [
        # Mathieu Lirzin
        "F2A3 8D7E EB2B 6640 5761  070D 0ADE E100 9460 4D37"
      ];
      outputHash = "5d05bb38a23fd3312b10aea93840feec685bdf4a41146e78882848165d3ae921";
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
