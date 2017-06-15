{ stdenv
, cmake
, fetchurl
, ninja
}:

let
  major = "1.1";
  version = "${major}.1";
  
  tarballUrls = [
    "https://cmocka.org/files/${major}/cmocka-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "cmocka-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    multihash = "QmZfvR3fkiLGFs52pp6RgohzsfAnguC1yRNtNS8KntAcVF";
    hashOutput = false;
    sha256 = "f02ef48a7039aa77191d525c5b1aee3f13286b77a13615d11bc1148753fc0389";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpDecompress = true;
      pgpsigUrls = map (n: "${n}.asc") tarballUrls;
      pgpKeyFingerprint = "8DFF 53E1 8F2A BC8D 8F3C  9223 7EE0 FC4D CC01 4E3D";
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
