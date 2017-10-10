{ stdenv
, bison
, fetchurl
, flex
, lib
}:

let
  version = "3.4.0";
  version' = lib.replaceStrings ["."] ["_"] version;
in
stdenv.mkDerivation rec {
  name = "libnl-${version}";

  src = fetchurl {
    url = "https://github.com/thom311/libnl/releases/download/"
      + "libnl${version'}/libnl-${version}.tar.gz";
    hashOutput = false;
    sha256 = "b7287637ae71c6db6f89e1422c995f0407ff2fe50cecd61a312b6a9b0921f5bf";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "49EA 7C67 0E08 50E7 4195  14F6 29C2 366E 4DFC 5728";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    homepage = "http://www.infradead.org/~tgr/libnl/";
    description = "Linux NetLink interface library";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
