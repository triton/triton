{ stdenv
, cmake
, fetchurl
, lib
, ninja
}:

let
  version = "1.2.2";
in
stdenv.mkDerivation rec {
  name = "libebur128-${version}";

  src = fetchurl {
    url = "https://github.com/jiixyj/libebur128/archive/v${version}.tar.gz";
    sha256 = "1d0d7e855da04010a2432e11fbc596502caf11b61c3b571ccbcb10095fe44b43";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DENABLE_INTERNAL_QUEUE_H=OFF"
    "-DBUILD_STATIC_LIBS=OFF"
    "-DENABLE_TESTS=OFF"
  ];

  meta = with lib; {
    description = "A library implementing the EBU R128 loudness standard.";
    homepage = https://github.com/jiixyj/libebur128;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
