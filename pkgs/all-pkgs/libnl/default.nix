{ stdenv
, bison
, fetchurl
, flex
}:

let
  version = "3.2.28";
  version' = stdenv.lib.replaceStrings ["."] ["_"] version;
in
stdenv.mkDerivation rec {
  name = "libnl-${version}";

  src = fetchurl {
    url = "https://github.com/thom311/libnl/releases/download/libnl${version'}/libnl-${version}.tar.gz";
    allowHashOutput = false;
    sha256 = "cd608992c656e8f6e3ab6c1391b162a5a51c49336b9219f7f390e61fc5437c41";
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
