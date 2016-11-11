{ stdenv
, cmake
, fetchurl
, lib
, ninja
}:

let
  version = "1.2.0";
in
stdenv.mkDerivation rec {
  name = "libebur128-${version}";

  src = fetchurl {
    url = "https://github.com/jiixyj/libebur128/archive/v${version}.tar.gz";
    sha256 = "f4c4ce732ae085214bcc47349f89b61ed53c13721c097e01cb966533ee6b1e5b";
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
