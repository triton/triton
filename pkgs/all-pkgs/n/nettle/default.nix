{ stdenv
, fetchurl
, gnum4

, gmp
}:

let
  tarballUrls = version: [
    "mirror://gnu/nettle/nettle-${version}.tar.gz"
  ];

  version = "3.3";
in
stdenv.mkDerivation rec {
  name = "nettle-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "46942627d5d0ca11720fec18d81fc38f7ef837ea4197c1f630e71ce0d470b11e";
  };

  nativeBuildInputs = [
    gnum4
  ];

  buildInputs = [
    gmp
  ];

  doCheck = true;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "3.3";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "343C 2FF0 FBEE 5EC2 EDBE  F399 F359 9FF8 28C6 7298";
      inherit (src) outputHashAlgo;
      outputHash = "46942627d5d0ca11720fec18d81fc38f7ef837ea4197c1f630e71ce0d470b11e";
    };
  };

  meta = with stdenv.lib; {
    description = "Cryptographic library";
    homepage = http://www.lysator.liu.se/~nisse/nettle/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
