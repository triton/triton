{ stdenv
, bison
, fetchFromGitHub
, flex

, ceph
, glusterfs
, libaio
, libibverbs
, librdmacm
, numactl
, zlib
}:

stdenv.mkDerivation rec {
  name = "fio-2.17";

  src = fetchFromGitHub {
    version = 2;
    owner = "axboe";
    repo = "fio";
    rev = name;
    sha256 = "15026a318705babb4fc5a587d6d251303248d913e0c7bc9e7e53883588d2dcba";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    ceph
    glusterfs
    libaio
    libibverbs
    librdmacm
    numactl
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
