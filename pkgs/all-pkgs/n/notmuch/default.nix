{ stdenv
, fetchurl
, python3Packages

, glib
, gmime
, talloc
, xapian-core
, zlib
}:

stdenv.mkDerivation rec {
  name = "notmuch-0.27";

  src = fetchurl {
    url = "https://notmuchmail.org/releases/${name}.tar.gz";
    multihash = "QmfEazSXLR8weU9Q5nEvNoogth4dn4yFjqFTdBoiYHpCDE";
    hashOutput = false;
    sha256 = "40d3192f8f130f227b511fc80be86310c7f60ccb6d043b563f201fa505de0876";
  };

  nativeBuildInputs = [
    python3Packages.python
    python3Packages.sphinx
  ];

  buildInputs = [
    glib
    gmime
    talloc
    xapian-core
    zlib
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha256Urls = map (n: "${n}.sha256.asc") src.urls;
      pgpKeyFingerprint = "815B 6398 2A79 F8E7 C727  86C4 762B 57BB 7842 06AD";
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
