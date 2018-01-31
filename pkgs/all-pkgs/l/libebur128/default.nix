{ stdenv
, cmake
, fetchzip
, lib
, ninja
}:

let
  version = "1.2.4";
in
stdenv.mkDerivation rec {
  name = "libebur128-${version}";

  src = fetchzip {
    version = 5;
    url = "https://github.com/jiixyj/libebur128/archive/v${version}.tar.gz";
    sha256 = "4ee70ac0aa4feefd17dfa48b9d9229e97b1ba4069b6b336215e142e0b2acdddc";
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
