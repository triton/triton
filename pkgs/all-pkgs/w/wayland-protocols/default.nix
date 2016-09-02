{ stdenv
, fetchurl

, wayland
}:

stdenv.mkDerivation rec {
  name = "wayland-protocols-1.7";

  src = fetchurl {
    url = "https://wayland.freedesktop.org/releases/${name}.tar.xz";
    hashOutput = false;
    sha256 = "635f2a937d318f1fecb97b54074ca211486e38af943868dd0fa82ea38d091c1f";
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
