{ stdenv
, fetchurl
, perl
, texinfo
}:

let
  tarballUrls = version: [
    "mirror://gnu/libtasn1/libtasn1-${version}.tar.gz"
  ];

  version = "4.9";
in
stdenv.mkDerivation rec {
  name = "libtasn1-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "4f6f7a8fd691ac2b8307c8ca365bad711db607d4ad5966f6938a9d2ecd65c920";
  };

  nativeBuildInputs = [
    perl
    texinfo
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "4.9";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "1F42 4189 05D8 206A A754  CCDC 29EE 58B9 9686 5171";
      outputHash = "4f6f7a8fd691ac2b8307c8ca365bad711db607d4ad5966f6938a9d2ecd65c920";
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
