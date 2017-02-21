{ stdenv
, fetchurl

, libftdi
, libusb
, libusb-compat
, pciutils
}:

stdenv.mkDerivation rec {
  name = "flashrom-0.9.9";

  src = fetchurl {
    url = "http://download.flashrom.org/releases/${name}.tar.bz2";
    multihash = "QmduQg4FtuWiFXGee4Ktj3NmW4A4uYFYD7MLWVzGhyBCaK";
    hashOutput = false;
    sha256 = "cb3156b0f63eb192024b76c0814135930297aac41f80761a5d293de769783c45";
  };

  buildInputs = [
    libftdi
    libusb
    libusb-compat
    pciutils
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        "3C9E 58F2 0C1F 1B3B 471E  5248 918F 0230 023D F00B"
        "52CF 1C6C 8705 AADC 78D4  A060 45D3 4CCF 6785 FC01"
      ];
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
