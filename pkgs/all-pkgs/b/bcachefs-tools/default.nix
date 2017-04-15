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

let
  date = "2017-04-15";
  rev = "1b495cf9e1c75d19cb1bff9b0b13d03c9a62153c";
in
stdenv.mkDerivation {
  name = "bcache-tools-2017-04-15";

  src = fetchzip {
    version = 2;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-${rev}.tar.xz";
    multihash = "QmZoMB9nzB9QgjrX8o2NDBaxBE9jMPzWc4vXUZciMjAjRr";
    sha256 = "8337500fe2f602af30231b6b009f8aeacfeec074fa4e2fbf37ef2e1603e70cf8";
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
