{ stdenv
, cmake
, fetchurl
, lib
, ninja
}:

let
  version = "1.3.12";
in
stdenv.mkDerivation rec {
  name = "graphite2-${version}";

  src = fetchurl {
    url = "https://github.com/silnrsi/graphite/releases/download/${version}/"
      + "${name}.tgz";
    hashOutput = false;
    sha256 = "cd9530c16955c181149f9af1f13743643771cb920c75a04c95c77c871a2029d0";
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
