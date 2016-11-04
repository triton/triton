{ stdenv
, fetchurl
, lib

, alsa-lib
}:

let
  inherit (lib)
    boolString
    boolWt;

  channel = "2.0";
  version = "2.0.0";
in
stdenv.mkDerivation rec {
  name = "flite-${version}";

  src = fetchurl {
    url = "http://www.festvox.org/flite/packed/flite-${channel}/"
      + "${name}-release.tar.bz2";
    multihash = "Qmb65TZM2ogBBMArgsTiCBL7bry5jZvmeezr5kQ9nXBtyo";
    sha256 = "678c3860fd539402b5d1699b921239072af6acb4e72dc4720494112807cae411";
  };

  buildInputs = [
    alsa-lib
  ];

  configureFlags = [
    "--enable-shared"
    "--enable-sockets"
    "--${boolWt (alsa-lib != null)}-audio${
        boolString (alsa-lib != null) "=alsa" ""}"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
        insecureHashOutput = true;
    };
  };

  meta = with lib; {
    description = "A small, fast run-time speech synthesis engine";
    homepage = http://www.festvox.org/flite/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
