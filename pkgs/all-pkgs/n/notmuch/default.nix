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
  name = "notmuch-0.23.3";

  src = fetchurl {
    url = "https://notmuchmail.org/releases/${name}.tar.gz";
    multihash = "QmfXVS7kzuDJgL5HnNSWQ5jcpBQkeH7yoqrqw39m1njdWt";
    hashOutput = false;
    sha256 = "0f5da5cf0203b774e345c50d56e975a87c2fc5407ef4ea284b6e2b55a8951882";
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
