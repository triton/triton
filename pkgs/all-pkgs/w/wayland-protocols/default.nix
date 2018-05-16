{ stdenv
, fetchurl
, lib

, wayland
}:

stdenv.mkDerivation rec {
  name = "wayland-protocols-1.14";

  src = fetchurl {
    url = "https://wayland.freedesktop.org/releases/${name}.tar.xz";
    multihash = "Qma39CZMJMasLoVyFe6tuN7sG8ZsWsnpvyBCtoAbNyTHPN";
    hashOutput = false;
    sha256 = "9648896b2462b49b15a69b60f44656593c170c0e73121c890eb16d0c1d9376f6";
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
