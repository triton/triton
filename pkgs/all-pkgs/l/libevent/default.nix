{ stdenv
, fetchurl
, python

, openssl
}:

let
  version = "2.0.22";

  tarballUrls = version: [
    "https://github.com/libevent/libevent/releases/download/release-${version}-stable/libevent-${version}-stable.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libevent-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "18qz9qfwrkakmazdlwxvjmw8p76g70n3faikwvdwznns1agw9hki";
  };

  nativeBuildInputs = [
    python
  ];

  buildInputs = [
    openssl
  ];

  patchPhase = ''
    patchShebangs event_rpcgen.py
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.0.22";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "B35B F85B F194 89D0 4E28  C33C 2119 4EBB 1657 33EA";
      inherit (src) outputHashAlgo;
      outputHash = "18qz9qfwrkakmazdlwxvjmw8p76g70n3faikwvdwznns1agw9hki";
    };
  };

  meta = with stdenv.lib; {
    description = "Event notification library";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
