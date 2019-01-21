{ stdenv
, fetchurl

, openssl
, python2
}:

let
  version = "2.1.8";

  tarballUrls = version: [
    "https://github.com/libevent/libevent/releases/download/release-${version}-stable/libevent-${version}-stable.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libevent-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "965cc5a8bb46ce4199a47e9b2c9e1cae3b137e8356ffdad6d94d3b9069b71dc2";
  };

  buildInputs = [
    openssl
    python2
  ];

  patchPhase = ''
    patchShebangs event_rpcgen.py
  '';

  configureFlags = [
    "--enable-gcc-hardening"
    "--disable-samples"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.1.8";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprints = [
        "9E3A C83A 2797 4B84 D1B3  401D B860 8684 8EF8 686D"
      ];
      inherit (src) outputHashAlgo;
      outputHash = "965cc5a8bb46ce4199a47e9b2c9e1cae3b137e8356ffdad6d94d3b9069b71dc2";
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
