{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

stdenv.mkDerivation rec {
  name = "libutp-2016-05-25";

  src = fetchFromGitHub {
    version = 2;
    owner = "bittorrent";
    repo = "libutp";
    rev = "31103141c4101bc05bfe4c622cb77d17ff90c0f1";
    sha256 = "2702fb5d8d96bcd4b3957e90092db01c9906b3047db9f909b5e6083bf2c0bd5c";
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
