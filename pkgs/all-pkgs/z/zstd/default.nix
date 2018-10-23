{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

let
  version = "1.3.7";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "facebook";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "3fbef86029710fa8ad72ca473677163b4fdc0bbda0aac2b28151a7fd067bc026";
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
