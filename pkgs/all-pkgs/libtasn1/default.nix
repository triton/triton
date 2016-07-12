{ stdenv
, fetchurl
, perl
, texinfo
}:

let
  tarballUrls = version: [
    "mirror://gnu/libtasn1/libtasn1-${version}.tar.gz"
  ];

  version = "4.8";
in
stdenv.mkDerivation rec {
  name = "libtasn1-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    allowHashOutput = false;
    sha256 = "fa802fc94d79baa00e7397cedf29eb6827d4bd8b4dd77b577373577c93a8c513";
  };

  nativeBuildInputs = [
    perl
    texinfo
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "4.8";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "1F42 4189 05D8 206A A754  CCDC 29EE 58B9 9686 5171";
      outputHash = "fa802fc94d79baa00e7397cedf29eb6827d4bd8b4dd77b577373577c93a8c513";
      inherit (src) outputHashAlgo;
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
