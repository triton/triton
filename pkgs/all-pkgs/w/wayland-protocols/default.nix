{ stdenv
, fetchurl
, lib

, wayland
}:

stdenv.mkDerivation rec {
  name = "wayland-protocols-1.13";

  src = fetchurl {
    url = "https://wayland.freedesktop.org/releases/${name}.tar.xz";
    multihash = "QmUqmaJ5BRkEoxYbJDh2yPES6DqZMak5qK1pnoE2BfEFZQ";
    hashOutput = false;
    sha256 = "0758bc8008d5332f431b2a84fea7de64d971ce270ed208206a098ff2ebc68f38";
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
