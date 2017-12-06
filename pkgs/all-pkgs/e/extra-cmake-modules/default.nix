{ stdenv
, cmake
, fetchurl
, ninja
}:

let
  majorVersion = "5.40";
  patchVersion = "0";
  version = "${majorVersion}.${patchVersion}";
in
stdenv.mkDerivation rec {
  name = "extra-cmake-modules-${version}";

  src = fetchurl {
    url = "mirror://kde/stable/frameworks/${majorVersion}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "83e48889c84474e4f560e10e4eea0cc529f8511b3bd0415fcb898ac0496e630a";
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
