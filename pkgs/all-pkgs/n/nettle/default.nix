{ stdenv
, fetchurl
, gnum4

, gmp
}:

let
  tarballUrls = version: [
    "mirror://gnu/nettle/nettle-${version}.tar.gz"
  ];

  version = "3.4";
in
stdenv.mkDerivation rec {
  name = "nettle-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "ae7a42df026550b85daca8389b6a60ba6313b0567f374392e54918588a411e94";
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
      urls = tarballUrls "3.4";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "343C 2FF0 FBEE 5EC2 EDBE  F399 F359 9FF8 28C6 7298";
      inherit (src) outputHashAlgo;
      outputHash = "ae7a42df026550b85daca8389b6a60ba6313b0567f374392e54918588a411e94";
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
