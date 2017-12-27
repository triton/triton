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
  date = "2017-12-23";
  rev = "30caf69540dfb3913e8b5c0359f7714dd52a08cb";
in
stdenv.mkDerivation {
  name = "bcache-tools-${date}";

  src = fetchzip {
    version = 5;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-${rev}.tar.xz";
    multihash = "QmWtB2bA8dvcVEL3euscAK2gA4ssUbMUH3vhPPtndLHZKY";
    sha256 = "ae1c18e70b3cdf8528e2733130692d334a96d3abdfe8d8b7dada25d317fe6cf4";
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
