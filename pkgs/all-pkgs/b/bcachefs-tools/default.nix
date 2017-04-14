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
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-03bc9d71b13e6f8e879894f93ea16f1f4a8280c9.tar.xz";
    multihash = "QmXtdmAb8k6QUpAx1keGHPqLMSYMWDnoTKEHK1ZTYQjh38";
    sha256 = "509fc6b9d9621d9e19b68bece86533b2719c1e51dd6997baf9c2524b74529324";
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
