{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

let
  version = "1.3.5";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "facebook";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "170f911bff1622f617df561adda40176594ebba791c0e52cc428701aa7699569";
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
