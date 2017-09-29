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
  name = "fio-3.1";

  src = fetchFromGitHub {
    version = 3;
    owner = "axboe";
    repo = "fio";
    rev = name;
    sha256 = "0a3a16d677cea18574a73cf62a1d91b4ab02a8d4cdd003673f173429e7f48717";
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
