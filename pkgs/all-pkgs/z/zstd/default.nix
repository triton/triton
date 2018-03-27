{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

let
  version = "1.3.4";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "facebook";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "ac8a9855f2194d8699d9ac40c7eeb30af76c75b714eccf5407f07bb71dc3801a";
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
