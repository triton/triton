{ stdenv
, lib
, fetchTritonPatch
, fetchurl

, libcdio

, type ? "lib"
}:

let
  version = "0.7.24";
in
stdenv.mkDerivation rec {
  name = "vcdimager-${version}";

  src = fetchurl {
    url = "mirror://gnu/vcdimager/${name}.tar.gz";
    hashOutput = false;
    sha256 = "075d7a67353ff3004745da781435698b6bc4a053838d0d4a3ce0516d7d974694";
  };

  patches = [
    (fetchTritonPatch {
      rev = "5a4e17f35575797151ff05c5fbd1ae7351aaec5c";
      file = "v/vcdimager/fix-libcdio-0.83.patch";
      sha256 = "2dec35e45361c5d7ca11b342f66463b5ce667db3df9d4dc2ac63f101fa183959";
    })
  ];

  buildInputs = [
    libcdio
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "DAA6 3BC2 5820 34A0 2B92  3D52 1A8D E500 8275 EC21";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
