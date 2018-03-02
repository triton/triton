{ stdenv
, fetchurl
, autoconf
, perl
}:

let
  version = "1.16";

  tarballUrls = version: [
    "mirror://gnu/automake/automake-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "automake-${version}";

  src = fetchurl {
    url = tarballUrls version;
    hashOutput = false;
    sha256 = "f98f2d97b11851cbe7c2d4b4eaef498ae9d17a3c2ef1401609b7b4ca66655b8a";
  };

  nativeBuildInputs = [
    perl
    autoconf
  ];

  setupHook = ./setup-hook.sh;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.16";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprints = [
        # Mathieu Lirzin
        "F2A3 8D7E EB2B 6640 5761  070D 0ADE E100 9460 4D37"
      ];
      outputHash = "f98f2d97b11851cbe7c2d4b4eaef498ae9d17a3c2ef1401609b7b4ca66655b8a";
      inherit (src) outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "GNU standard-compliant makefile generator";
    homepage = "http://www.gnu.org/software/automake/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux
      ++ i686-linux;
    branch = "1.15";
  };
}
