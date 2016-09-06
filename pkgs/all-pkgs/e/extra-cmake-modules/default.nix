{ stdenv
, cmake
, fetchurl
, ninja
}:

let
  majorVersion = "5.25";
  patchVersion = "0";
  version = "${majorVersion}.${patchVersion}";
in
stdenv.mkDerivation rec {
  name = "extra-cmake-modules-${version}";

  src = fetchurl {
    url = "mirror://kde/stable/frameworks/${majorVersion}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "73c90e67c328076c2bee35884836087e7e9f753e48fc0063c8348b6f66b0345f";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
