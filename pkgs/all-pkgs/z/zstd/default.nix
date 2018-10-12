{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

let
  version = "1.3.6";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "facebook";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "b77372b37639e0f3fbd7ff424bf379b5a6bf62c702a7d656585316b7310d6e61";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  postPatch = ''
    cd build/cmake
  '';

  cmakeFlags = [
    "-DZSTD_BUILD_CONTRIB=ON"
  ];

  meta = with lib; {
    description = "Fast real-time lossless compression algorithm";
    homepage = http://www.zstd.net/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
