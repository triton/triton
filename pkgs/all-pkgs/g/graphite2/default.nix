{ stdenv
, cmake
, fetchurl
, lib
, ninja
}:

let
  version = "1.3.13";
in
stdenv.mkDerivation rec {
  name = "graphite2-${version}";

  src = fetchurl {
    url = "https://github.com/silnrsi/graphite/releases/download/${version}/"
      + "${name}.tgz";
    hashOutput = false;
    sha256 = "dd63e169b0d3cf954b397c122551ab9343e0696fb2045e1b326db0202d875f06";
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
