{ stdenv
, fetchurl
, autoconf
, perl
}:

let
  version = "1.15.1";

  tarballUrls = version: [
    "mirror://gnu/automake/automake-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "automake-${version}";

  src = fetchurl {
    url = tarballUrls version;
    sha256 = "af6ba39142220687c500f79b4aa2f181d9b24e4f8d8ec497cea4ba26c64bedaf";
  };

  nativeBuildInputs = [
    perl
    autoconf
  ];

  setupHook = ./setup-hook.sh;

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src) outputHashAlgo;
      urls = tarballUrls "1.15.1";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprints = [
        # Mathieu Lirzin
        "F2A3 8D7E EB2B 6640 5761  070D 0ADE E100 9460 4D37"
      ];
      outputHash = "af6ba39142220687c500f79b4aa2f181d9b24e4f8d8ec497cea4ba26c64bedaf";
      failEarly = true;
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
