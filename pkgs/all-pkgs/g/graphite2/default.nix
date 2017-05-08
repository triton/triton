{ stdenv
, cmake
, fetchurl
, lib
, ninja
}:

let
  version = "1.3.10";
in
stdenv.mkDerivation rec {
  name = "graphite2-${version}";

  src = fetchurl {
    url = "https://github.com/silnrsi/graphite/releases/download/${version}/"
      + "${name}.tgz";
    hashOutput = false;
    sha256 = "90fde3b2f9ea95d68ffb19278d07d9b8a7efa5ba0e413bebcea802ce05cda1ae";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  # cmakeFlags = [
  #   "-DGRAPHITE2_ASAN=ON"
  # ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha1Url = "https://github.com/silnrsi/graphite/releases/download/"
        + "${version}/${name}.sha1sum";
      failEarly = true;
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
