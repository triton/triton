{ stdenv
, fetchurl
, pythonPackages

, glib
, gmime
, talloc
, xapian-core
, zlib
}:

stdenv.mkDerivation rec {
  name = "notmuch-0.23.5";

  src = fetchurl {
    url = "https://notmuchmail.org/releases/${name}.tar.gz";
    multihash = "QmWGDK76zkQzh4J1kTsNKC5qds1dyU26FyaLtFr2SAjvBH";
    hashOutput = false;
    sha256 = "c62694b3c5f04db48ed3bbf37a801ea2a03439826c6be318e23b34de749ac267";
  };

  nativeBuildInputs = [
    pythonPackages.python
    pythonPackages.sphinx
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
      sha1Urls = map (n: "${n}.sha1.asc") src.urls;
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
