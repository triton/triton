{ stdenv
, fetchurl

, wayland
}:

stdenv.mkDerivation rec {
  name = "wayland-protocols-1.9";

  src = fetchurl {
    url = "https://wayland.freedesktop.org/releases/${name}.tar.xz";
    multihash = "QmVnZRKRyLgvdEMc9tBNNrqyvyNqXKt5QDaSfEWxw13AkN";
    hashOutput = false;
    sha256 = "666b72de30ca3b70c2b54ccc9e8114cb520e76db224c816b5e23501099174f75";
  };

  buildInputs = [
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

  meta = with stdenv.lib; {
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
