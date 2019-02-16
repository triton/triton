{ stdenv
, cmake
, fetchurl
, ninja
}:

let
  major = "1.1";
  version = "${major}.3";
in
stdenv.mkDerivation rec {
  name = "cmocka-${version}";

  src = fetchurl {
    url = "https://cmocka.org/files/${major}/cmocka-${version}.tar.xz";
    multihash = "QmZrFGJ6FnpnKYBnG7fZJH8hAVK4C3nyWxjLd1cgRS77JH";
    hashOutput = false;
    sha256 = "43eabcf72a9c80e3d03f7c8a1c04e408c18d2db5121eb058a3ef732a9dfabfaf";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprints = [
          # Andreas Schneider
          "8DFF 53E1 8F2A BC8D 8F3C  9223 7EE0 FC4D CC01 4E3D"
        ];
      };
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
