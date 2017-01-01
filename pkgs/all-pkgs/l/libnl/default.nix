{ stdenv
, bison
, fetchurl
, flex
}:

let
  version = "3.2.29";
  version' = stdenv.lib.replaceStrings ["."] ["_"] version;
in
stdenv.mkDerivation rec {
  name = "libnl-${version}";

  src = fetchurl {
    url = "https://github.com/thom311/libnl/releases/download/"
      + "libnl${version'}/libnl-${version}.tar.gz";
    hashOutput = false;
    sha256 = "0beb593dc6abfffa18a5c787b27884979c1b7e7f1fd468c801e3cc938a685922";
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

  meta = with stdenv.lib; {
    homepage = "http://www.infradead.org/~tgr/libnl/";
    description = "Linux NetLink interface library";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
