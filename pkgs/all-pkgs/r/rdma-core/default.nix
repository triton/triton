{ stdenv
, cmake
, fetchFromGitHub
, ninja
, python

, libnl
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "rdma-core-2017-04-03";

  src = fetchFromGitHub {
    version = 2;
    owner = "linux-rdma";
    repo = "rdma-core";
    rev = "8e6808615cd9eca8e433c9359034622ad2addda5";
    sha256 = "cb64b729103f66ab64514fe981706b7535548200a7b5994c80153eadfe770433";
  };

  nativeBuildInputs = [
    cmake
    ninja
    python
  ];

  buildInputs = [
    libnl
    systemd_lib
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
