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
  name = "fio-2.20";

  src = fetchFromGitHub {
    version = 3;
    owner = "axboe";
    repo = "fio";
    rev = name;
    sha256 = "770748651bae49e165d73cc26b0ecb22e7fdde9bf02d82c6bb7104a3361f6c84";
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
