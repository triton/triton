{ stdenv
, cmake
, fetchurl
, lib
, ninja
}:

let
  version = "1.3.14";
in
stdenv.mkDerivation rec {
  name = "graphite2-${version}";

  src = fetchurl {
    url = "https://github.com/silnrsi/graphite/releases/download/${version}/"
      + "${name}.tgz";
    hashOutput = false;
    sha256 = "f99d1c13aa5fa296898a181dff9b82fb25f6cc0933dbaa7a475d8109bd54209d";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      fullOpts = {
        sha1Url = "https://github.com/silnrsi/graphite/releases/download/"
          + "${version}/${name}.sha1sum";
      };
    };
  };

  meta = with lib; {
    description = "An advanced font engine";
    homepage = https://github.com/silnrsi/graphite;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
