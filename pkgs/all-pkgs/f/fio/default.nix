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
  name = "fio-2.18";

  src = fetchFromGitHub {
    version = 2;
    owner = "axboe";
    repo = "fio";
    rev = name;
    sha256 = "4f5296737b153968d5f23bb28a4563d18f28a3b4893b8558fcb977924c00c896";
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
