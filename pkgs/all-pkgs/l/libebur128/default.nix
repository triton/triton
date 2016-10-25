{ stdenv
, cmake
, fetchurl
, lib
, ninja
}:

let
  version = "1.1.0";
in
stdenv.mkDerivation rec {
  name = "libebur128-${version}";

  src = fetchurl {
    url = "https://github.com/jiixyj/libebur128/archive/v${version}.tar.gz";
    sha256 = "c60e78f4bfda387a0895c64a4fc9850445e3a4425cc98f9140885966ce17c1d1";
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
