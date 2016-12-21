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
  name = "fio-2.16";

  src = fetchFromGitHub {
    version = 2;
    owner = "axboe";
    repo = "fio";
    rev = name;
    sha256 = "945495bdba612e3082d8550da0781b8e8fda9719370adb3957ae813f2d17bc35";
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
