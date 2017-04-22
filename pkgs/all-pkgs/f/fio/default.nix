{ stdenv
, bison
, fetchFromGitHub
, flex

, ceph
, glusterfs
, libaio
, numactl
, rdma-core
, zlib
}:

stdenv.mkDerivation rec {
  name = "fio-2.19";

  src = fetchFromGitHub {
    version = 2;
    owner = "axboe";
    repo = "fio";
    rev = name;
    sha256 = "cf97688ff8a833c1aaa24370aeac5616d85373e9eb5b89cc4f1826cd96e9c23a";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    ceph
    glusterfs
    libaio
    numactl
    rdma-core
    zlib
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
