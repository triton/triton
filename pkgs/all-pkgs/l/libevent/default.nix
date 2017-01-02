{ stdenv
, autoreconfHook
, fetchFromGitHub
, python

, openssl
}:

let
  version = "2.1.7-rc";

  tarballUrls = version: [
    "https://github.com/libevent/libevent/releases/download/release-${version}-stable/libevent-${version}-stable.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libevent-${version}";

  /*src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "18qz9qfwrkakmazdlwxvjmw8p76g70n3faikwvdwznns1agw9hki";
  };*/

  src = fetchFromGitHub {
    version = 2;
    owner = "libevent";
    repo = "libevent";
    rev = "release-${version}";
    sha256 = "70a1e1042a1035f2e0d0d2edcb5eae84ca718b69a26803bebf6115e72dd5db41";
  };

  nativeBuildInputs = [
    autoreconfHook
    python
  ];

  buildInputs = [
    openssl
  ];

  patchPhase = ''
    patchShebangs event_rpcgen.py
  '';

  configureFlags = [
    "--disable-samples"
  ];

  /*passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.0.22";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "B35B F85B F194 89D0 4E28  C33C 2119 4EBB 1657 33EA";
      inherit (src) outputHashAlgo;
      outputHash = "18qz9qfwrkakmazdlwxvjmw8p76g70n3faikwvdwznns1agw9hki";
    };
  };*/

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
