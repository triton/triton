{ stdenv
, cmake
, fetchurl
, ninja

, qt5
}:

let
  version = "2.0.2";
in
stdenv.mkDerivation rec {
  name = "keepassx-${version}";

  src = fetchurl {
    url = "https://www.keepassx.org/releases/${version}/${name}.tar.gz";
    allowHashOutput = false;
    multihash = "QmV9iRABvuHbGxmS5qH9G92MCxsainUWpjLEQWTTHFYPtb";
    sha256 = "204bdcf49c72078cd6f02b4f29b062923cca9e7b2d3551f2bf352763daa236b8";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    qt5
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "164C 7051 2F79 2947 6764  AB56 FE22 C6FD 8313 5D45";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
