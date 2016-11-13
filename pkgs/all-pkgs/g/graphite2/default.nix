{ stdenv
, cmake
, fetchurl
, ninja
}:

let
  version = "1.3.9";
in
stdenv.mkDerivation rec {
  name = "graphite2-${version}";

  src = fetchurl {
    url = "https://github.com/silnrsi/graphite/releases/download/${version}/"
      + "${name}.tgz";
    hashOutput = false;
    sha256 = "ec0185b663059553fd46e8c4a4f0dede60a02f13a7a1fefc2ce70332ea814567";
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

  meta = with stdenv.lib; {
    description = "An advanced font engine";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
