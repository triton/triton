{ stdenv
, fetchurl
, gnum4

, gmp
}:

let
  tarballUrls = version: [
    "mirror://gnu/nettle/nettle-${version}.tar.gz"
  ];

  version = "3.6";
in
stdenv.mkDerivation rec {
  name = "nettle-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "d24c0d0f2abffbc8f4f34dcf114b0f131ec3774895f3555922fe2f40f3d5e3f1";
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
      urls = tarballUrls "3.6";
      inherit (src) outputHashAlgo;
      outputHash = "d24c0d0f2abffbc8f4f34dcf114b0f131ec3774895f3555922fe2f40f3d5e3f1";
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
