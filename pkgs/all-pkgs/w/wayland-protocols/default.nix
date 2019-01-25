{ stdenv
, fetchurl
, lib

, wayland
}:

stdenv.mkDerivation rec {
  name = "wayland-protocols-1.17";

  src = fetchurl {
    url = "https://wayland.freedesktop.org/releases/${name}.tar.xz";
    multihash = "QmZMQvqwp5wHSbRtPryzZjT2adePSSxvMdxxZcmW2MXZZB";
    hashOutput = false;
    sha256 = "df1319cf9705643aea9fd16f9056f4e5b2471bd10c0cc3713d4a4cdc23d6812f";
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
