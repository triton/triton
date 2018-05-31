{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

stdenv.mkDerivation rec {
  name = "libutp-2018-05-15";

  src = fetchFromGitHub {
    version = 6;
    owner = "bittorrent";
    repo = "libutp";
    rev = "2b364cbb0650bdab64a5de2abb4518f9f228ec44";
    sha256 = "9c180f50a9e8038bac50cbc94cceb0083d91b2dc11a4be6a112b71b226735192";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  postPatch = ''
    ln -sv ${./utp.pc.in} utp.pc.in
    ln -sv ${./CMakeLists.txt} CMakeLists.txt
  '';

  meta = with lib; {
    description = "uTorrent Transport Protocol library";
    homepage = https://github.com/bittorrent/libutp;
    licenses = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
