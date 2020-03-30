{ stdenv
, fetchurl
, lib

, wayland
}:

stdenv.mkDerivation rec {
  name = "wayland-protocols-1.20";

  src = fetchurl {
    url = "https://wayland.freedesktop.org/releases/${name}.tar.xz";
    multihash = "Qme5nZH7Pzx5SmuQWDh1BkLWKZhCDdiCiTYLhGSuJnamuF";
    hashOutput = false;
    sha256 = "9782b7a1a863d82d7c92478497d13c758f52e7da4f197aa16443f73de77e4de7";
  };

  nativeBuildInputs = [
    wayland
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
        pgpKeyFingerprint = "8307 C0A2 24BA BDA1 BABD  0EB9 A6EE EC9E 0136 164A";
      };
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
