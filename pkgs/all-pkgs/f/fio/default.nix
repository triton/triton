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
  name = "fio-3.6";

  src = fetchFromGitHub {
    version = 6;
    owner = "axboe";
    repo = "fio";
    rev = name;
    sha256 = "3cb15d97e9261a151f3b1520a1909ab5dcb779b601bfd307699d0c4cf65e296a";
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
