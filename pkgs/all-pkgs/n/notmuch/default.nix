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
  name = "notmuch-0.25.1";

  src = fetchurl {
    url = "https://notmuchmail.org/releases/${name}.tar.gz";
    multihash = "QmPTvFm9YtScuPPBy2egWt5RQm5c9d899jKK1bKfEvHNgA";
    hashOutput = false;
    sha256 = "b4bf09ec9b7b64180704faa26d66cad5f911a5a00ef812da34cb02c3f8872831";
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
