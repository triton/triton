{ stdenv
, fetchurl

, wayland
}:

stdenv.mkDerivation rec {
  name = "wayland-protocols-1.8";

  src = fetchurl {
    url = "https://wayland.freedesktop.org/releases/${name}.tar.xz";
    multihash = "QmQFiCB3yMbtBJTRm5EBu43VUdtdFz8JRURhE3R861kcuw";
    hashOutput = false;
    sha256 = "e3fa5f2812cfec3c1c2573bd34adfe37d4d8950dba572d9ec6c52adcc5fe4b9a";
  };

  buildInputs = [
    wayland
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "A66D 805F 7C93 29B4 C5D8  2767 CCC4 F07F AC64 1EFF";
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
