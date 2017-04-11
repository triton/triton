{ stdenv
, fetchzip

, attr
, keyutils
, libnih
, libscrypt
, libsodium
, liburcu
, util-linux_lib
, zlib
}:

stdenv.mkDerivation {
  name = "bcache-tools-2017-04-10";

  src = fetchzip {
    version = 2;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-e394bd4ba3934cea237ad699cae9fe86396d6f15.tar.xz";
    multihash = "QmWez7aUHLftCPnR1gnYMtEFF4PteLo7LhFTM6M1fDRpMX";
    sha256 = "ac4cf483598f392b5c97bea5b465b40feb245902fc74086b6719bd765ecab1cc";
  };

  buildInputs = [
    attr
    keyutils
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
