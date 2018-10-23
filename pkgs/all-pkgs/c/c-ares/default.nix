{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "https://c-ares.haxx.se/download/c-ares-${version}.tar.gz"
  ];

  version = "1.15.0";
in
stdenv.mkDerivation rec {
  name = "c-ares-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmPSBCLotU8oPBJFvCAh3Tj2RkRta5MJVqD7CPKMJ6Pa5r";
    hashOutput = false;
    sha256 = "6cdb97871f2930530c97deb7cf5c8fa4be5a0b02c7cea6e7c7667672a39d6852";
  };

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src) outputHashAlgo;
      urls = tarballUrls "1.15.0";
      outputHash = "6cdb97871f2930530c97deb7cf5c8fa4be5a0b02c7cea6e7c7667672a39d6852";
      failEarly = true;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprint = "27ED EAF2 2F3A BCEB 50DB  9A12 5CC9 08FD B71E 12C2";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "A C library for asynchronous DNS requests";
    homepage = http://c-ares.haxx.se;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
