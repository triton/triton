{ stdenv
, fetchurl
, lib

, wayland
}:

stdenv.mkDerivation rec {
  name = "wayland-protocols-1.16";

  src = fetchurl {
    url = "https://wayland.freedesktop.org/releases/${name}.tar.xz";
    multihash = "QmfVqT3FccL7W68UKXbQZvsTFLi84XCnynx7hi27bawGg1";
    hashOutput = false;
    sha256 = "6b1485951fdcd36a960c870c46f28b03a3e5121fb46246916333ed07f78c98c5";
  };

  nativeBuildInputs = [
    wayland
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "8307 C0A2 24BA BDA1 BABD  0EB9 A6EE EC9E 0136 164A";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "Wayland protocol files";
    homepage = https://wayland.freedesktop.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
