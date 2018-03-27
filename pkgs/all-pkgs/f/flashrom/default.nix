{ stdenv
, fetchurl

, libftdi
, libusb
, libusb-compat
, pciutils
}:

stdenv.mkDerivation rec {
  name = "flashrom-1.0";

  src = fetchurl {
    url = "https://download.flashrom.org/releases/${name}.tar.bz2";
    multihash = "QmZ3ZZdrjPAjf3bvWSounRTZSJ26uvFfKmsoazjo3CKf74";
    hashOutput = false;
    sha256 = "3702fa215ba5fb5af8e54c852d239899cfa1389194c1e51cb2a170c4dc9dee64";
  };

  buildInputs = [
    libftdi
    libusb
    libusb-compat
    pciutils
  ];

  postPatch = ''
    sed -i '/-Werror/d' Makefile
  '';

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
