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
  # Can't use 17.x until samba_full fixes usage of kern-abi.h
  version = "16.4";
in
stdenv.mkDerivation rec {
  name = "rdma-core-${version}";

  src = fetchurl {
    url = "https://github.com/linux-rdma/rdma-core/releases/download/v${version}/${name}.tar.gz";
    sha256 = "0550cc56e8d1f28e13ce3d9ef38c501e5f00117d97ee7cfd57b6aca581828e52";
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
