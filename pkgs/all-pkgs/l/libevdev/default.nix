{ stdenv
, fetchurl
, lib

, python
}:

stdenv.mkDerivation rec {
  name = "libevdev-1.5.9";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libevdev/${name}.tar.xz";
    multihash = "QmVGvpKPu8vhKHUrx2Vtco3PoMcjzW76pxChwv32vYr5VS";
    hashOutput = false;
    sha256 = "e1663751443bed9d3e76a4fe2caf6fa866a79705d91cacad815c04e706198a75";
  };

  buildInputs = [
    python
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
