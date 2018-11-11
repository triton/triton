{ stdenv
, fetchurl
, lib

, python3
}:

stdenv.mkDerivation rec {
  name = "libevdev-1.6.0";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libevdev/${name}.tar.xz";
    multihash = "QmWVBYNHH8J6JZXRu7NucPhBjKZfUDAv8LNePvjd2Fw4Bj";
    hashOutput = false;
    sha256 = "f5005c865987d980cc1279b9ec6131b06a89fd9892f649f2a68262b8786ef814";
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
