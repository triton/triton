{ stdenv
, fetchurl
, lib
, perl
, which
}:

stdenv.mkDerivation rec {
  name = "valgrind-3.13.0";

  src = fetchurl {
    url = "ftp://sourceware.org/pub/valgrind/valgrind-3.13.0.tar.bz2";
    multihash = "QmY9mtAA83mLKUeiEnhz2G4rV8QGE56t7E8TEgZQ816Swa";
    hashOutput = false;
    sha256 = "d76680ef03f00cd5e970bbdcd4e57fb1f6df7d2e2c071635ef2be74790190c3b";
  };

  nativeBuildInputs = [
    perl
    which
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-ubsan"
    "--enable-tls"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      md5Url = "ftp://sourceware.org/pub/valgrind/md5.sum";
      sha512Url = "ftp://sourceware.org/pub/valgrind/sha512.sum";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };
  
  stackProtector = false;

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
