{ stdenv
, fetchurl

, wayland
}:

stdenv.mkDerivation rec {
  name = "wayland-protocols-1.4";

  src = fetchurl {
    url = "https://wayland.freedesktop.org/releases/${name}.tar.xz";
    allowHashOutput = false;
    sha256 = "014a9a23c21ed14f49b1005b3e8efa66d6337d4ceafc97f7b0d6707e7e3df572";
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
    homepage = http://wayland.freedesktop.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
