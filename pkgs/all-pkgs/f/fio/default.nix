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
  name = "fio-3.3";

  src = fetchFromGitHub {
    version = 5;
    owner = "axboe";
    repo = "fio";
    rev = name;
    sha256 = "adf4c7e3f1917239b72776333d5acbd48c79b52617e5b8614e7b5a539d2e1a18";
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
