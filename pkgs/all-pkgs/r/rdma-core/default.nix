{ stdenv
, cmake
, fetchurl
, lib
, ninja
, python

, libnl
, systemd_lib
}:

let
  version = "17";
in
stdenv.mkDerivation rec {
  name = "rdma-core-${version}";

  src = fetchurl {
    url = "https://github.com/linux-rdma/rdma-core/releases/download/v${version}/${name}.tar.gz";
    sha256 = "28a8e3d540decef59b206a8bb103d37ea5b50510b7999b1b9fef0aa27a5beeb9";
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

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
