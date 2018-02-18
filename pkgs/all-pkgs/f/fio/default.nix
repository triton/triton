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
  name = "fio-3.4";

  src = fetchFromGitHub {
    version = 5;
    owner = "axboe";
    repo = "fio";
    rev = name;
    sha256 = "df962c5a2e92f4172e1329e0581d8c3304fef5c22c333dc00bfde35c6669c1ee";
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
