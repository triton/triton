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
  name = "notmuch-0.25";

  src = fetchurl {
    url = "https://notmuchmail.org/releases/${name}.tar.gz";
    multihash = "QmZ2mNC3AMEqgCM5zipuA7sYWGdaQZbG6pmedHsyBMY7tF";
    hashOutput = false;
    sha256 = "65d28d1f783d02629039f7d15d9a2bada147a7d3809f86fe8d13861b0f6ae60b";
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
