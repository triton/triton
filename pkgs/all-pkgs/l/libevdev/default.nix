{ stdenv
, fetchurl
, lib

, python
}:

stdenv.mkDerivation rec {
  name = "libevdev-1.5.8";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libevdev/${name}.tar.xz";
    multihash = "QmQQzJEnHadz6m1Bpjf5FetzoEpS89TZ7yczdsRYqXUCWD";
    hashOutput = false;
    sha256 = "6083d81e46609da8ba80cb826c02d9080764a6dec33c8267ccb7e158833d4c6d";
  };

  buildInputs = [
    python
  ];

  configureFlags = [
    "--disable-silent"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "3C2C 43D9 447D 5938 EF45  51EB E23B 7E70 B467 F0BF";
      inherit (src) urls outputHash outputHashAlgo;
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
