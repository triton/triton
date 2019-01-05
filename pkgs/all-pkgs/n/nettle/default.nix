{ stdenv
, fetchurl
, gnum4

, gmp
}:

let
  tarballUrls = version: [
    "mirror://gnu/nettle/nettle-${version}.tar.gz"
  ];

  version = "3.4.1";
in
stdenv.mkDerivation rec {
  name = "nettle-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "f941cf1535cd5d1819be5ccae5babef01f6db611f9b5a777bae9c7604b8a92ad";
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
      urls = tarballUrls "3.4.1";
      inherit (src) outputHashAlgo;
      outputHash = "f941cf1535cd5d1819be5ccae5babef01f6db611f9b5a777bae9c7604b8a92ad";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "343C 2FF0 FBEE 5EC2 EDBE  F399 F359 9FF8 28C6 7298";
      };
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
