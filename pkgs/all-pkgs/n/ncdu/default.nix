{ stdenv
, lib
, fetchurl

, ncurses
}:

stdenv.mkDerivation rec {
  name = "ncdu-1.14";

  src = fetchurl {
    url = "https://dev.yorhel.nl/download/${name}.tar.gz";
    multihash = "QmTyUbhJ8zhm2NjGThFstGMDabebaaPDij6NZSq1gxhDYA";
    hashOutput = false;
    sha256 = "c694783aab21e27e64baad314b7c1ff34541bfa219fe9645ef6780f1c5558c44";
  };
  
  buildInputs = [
    ncurses
  ];

  postFixup = ''
    rm -rv "$bin"/share
  '';

  outputs = [
    "bin"
    "man"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src) urls outputHash outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "7446 0D32 B808 10EB A9AF  A2E9 6239 4C69 8C27 39FA";
      };
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
