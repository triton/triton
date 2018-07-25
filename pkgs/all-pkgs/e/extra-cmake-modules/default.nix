{ stdenv
, cmake
, fetchurl
, ninja
}:

let
  majorVersion = "5.48";
  patchVersion = "0";
  version = "${majorVersion}.${patchVersion}";
in
stdenv.mkDerivation rec {
  name = "extra-cmake-modules-${version}";

  src = fetchurl {
    url = "mirror://kde/stable/frameworks/${majorVersion}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "fc5b7a9dedb4f6a91db17482578c33f1ec55f11791c592ee431f6d9898ede598";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "53E6 B47B 45CE A3E0 D5B7  4577 58D0 EE64 8A48 B3BB";
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
