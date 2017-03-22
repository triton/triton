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
  name = "bcache-tools-2017-03-19";

  src = fetchzip {
    version = 2;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-c0ad33c126300a51721a4f0ec8c0d757647e9cbe.tar.xz";
    multihash = "QmZNbQ1ZmDowe9ShQxVrfZSPHEPMhbrGsbZmGqVVq5zFpL";
    sha256 = "45ba820507e0468058e4875d87550fa69586d1e5a12bd8d8775ac4dfb5de1eb3";
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
