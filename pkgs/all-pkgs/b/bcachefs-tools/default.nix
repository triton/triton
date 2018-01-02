{ stdenv
, fetchzip

, attr
, keyutils
, libaio
, libnih
, libscrypt
, libsodium
, liburcu
, util-linux_lib
, zlib
}:

let
  date = "2017-12-30";
  rev = "f8cbede6d18e81c804e62fd7d576310b420dcaac";
in
stdenv.mkDerivation {
  name = "bcache-tools-${date}";

  src = fetchzip {
    version = 5;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-${rev}.tar.xz";
    multihash = "QmPzfHHWZFEyqSvfHzGpQmbbdCD8GBcMQy1MJAgu9Q4Y1A";
    sha256 = "1ca2dc29d9adec45ffa67f5fe79d760540bd54ffcdc9a27a74b70ebbd6d9d2dc";
  };

  buildInputs = [
    attr
    keyutils
    libaio
    libnih
    libscrypt
    libsodium
    liburcu
    util-linux_lib
    zlib
  ];

  postPatch = ''
    sed -i 's,<blkid.h>,<blkid/blkid.h>,g' tools-util.c
    sed -i 's,</usr/include/dirent.h>,<${stdenv.libc}/include/dirent.h>,g' cmd_migrate.c

    sed -i '/-static/d' Makefile
  '';

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
      "UDEVLIBDIR=$out/lib/udev"
    )
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
