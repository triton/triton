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
  name = "notmuch-0.28.1";

  src = fetchurl {
    url = "https://notmuchmail.org/releases/${name}.tar.gz";
    multihash = "Qmf9XaXBKVGfBYnGamDmcLT3S5L7XCFNW9k8pz1VYYiqmf";
    hashOutput = false;
    sha256 = "d111e938137d5a465afc2b133d14df1fa356537d9ce752c919fe5673f3749a55";
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
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        sha256Urls = map (n: "${n}.sha256.asc") src.urls;
        pgpKeyFingerprint = "815B 6398 2A79 F8E7 C727  86C4 762B 57BB 7842 06AD";
      };
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
