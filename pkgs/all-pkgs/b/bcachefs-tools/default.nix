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
  date = "2017-04-24";
  rev = "e41920e6036c3fb6b91edac44a56630cf13d8027";
in
stdenv.mkDerivation {
  name = "bcache-tools-${date}";

  src = fetchzip {
    version = 2;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-${rev}.tar.xz";
    multihash = "QmdQpnCq25ydfDjsABmSG77PrJKDuSxciuZUKxKtWkbBVg";
    sha256 = "b3e92df860f9be3a00713e148e5541ee5f0d48387932a28f91710b98829c772f";
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
