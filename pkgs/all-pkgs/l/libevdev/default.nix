{ stdenv
, fetchurl
, lib

, python3
}:

stdenv.mkDerivation rec {
  name = "libevdev-1.7.0";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libevdev/${name}.tar.xz";
    multihash = "QmUSt7QTevh6VWiwiwnTHprCR3Rz2VCYkAqhmJBvD57Lpc";
    hashOutput = false;
    sha256 = "11dbe1f2b1d03a51f3e9a196757a75c3a999042ce34cf1fdc00a2363e5a2e369";
  };

  nativeBuildInputs = [
    python3
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "3C2C 43D9 447D 5938 EF45  51EB E23B 7E70 B467 F0BF";
      };
    };
  };

  meta = with lib; {
    description = "Wrapper library for evdev devices";
    homepage = http://www.freedesktop.org/software/libevdev/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
