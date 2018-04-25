{ stdenv
, cmake
, fetchurl
, lib
, ninja
}:

let
  version = "1.3.11";
in
stdenv.mkDerivation rec {
  name = "graphite2-${version}";

  src = fetchurl {
    url = "https://github.com/silnrsi/graphite/releases/download/${version}/"
      + "${name}.tgz";
    hashOutput = false;
    sha256 = "bab92ed1844d6538e7e5bda76f6ac9aaf633e38b683983b942c78c8ce063ad7c";
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
