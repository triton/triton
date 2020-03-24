{ stdenv
, fetchTritonPatch
, fetchurl
, perl
, texinfo
}:

let
  tarballUrls = version: [
    "mirror://gnu/libtasn1/libtasn1-${version}.tar.gz"
  ];

  version = "4.16.0";
in
stdenv.mkDerivation rec {
  name = "libtasn1-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "0e0fb0903839117cb6e3b56e68222771bebf22ad7fc2295a0ed7d576e8d4329d";
  };

  nativeBuildInputs = [
    perl
    texinfo
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "4.14";
      outputHash = "9e604ba5c5c8ea403487695c2e407405820d98540d9de884d6e844f9a9c5ba08";
      inherit (src) outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "1F42 4189 05D8 206A A754  CCDC 29EE 58B9 9686 5171";
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/libtasn1/;
    description = "An ASN.1 library";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
