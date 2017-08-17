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
  name = "fio-3.0";

  src = fetchFromGitHub {
    version = 3;
    owner = "axboe";
    repo = "fio";
    rev = name;
    sha256 = "a1b5b2dcae18d9b0de5364e21bdfd0fe54b95dd1d9c7bade50a5ff7f770f610f";
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
