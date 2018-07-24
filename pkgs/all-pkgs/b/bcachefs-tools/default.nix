{ stdenv
, fetchzip

, keyutils
, libaio
, libnih
, libscrypt
, libsodium
, liburcu
, lz4
, util-linux_lib
, zlib
, zstd
}:

let
  date = "2018-07-20";
  rev = "b5094ee8546ab9dbe099ee5fb0ef91af16b47f96";
in
stdenv.mkDerivation {
  name = "bcachefs-tools-${date}";

  src = fetchzip {
    version = 6;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-${rev}.tar.xz";
    multihash = "Qmb88Qt8q1vcbeNtmJZW7frZAmWuGR71aTEqXqoANfpbVA";
    sha256 = "d3fa52085d853c45510bd33ecb84b25d0e1fe3082d2ccf442585abfd2cf97ad3";
  };

  buildInputs = [
    keyutils
    libaio
    libnih
    libscrypt
    libsodium
    liburcu
    lz4
    util-linux_lib
    zlib
    zstd
  ];

  postPatch = ''
    grep -q 'attr/xattr.h' cmd_migrate.c
    sed -i 's,attr/xattr.h,sys/xattr.h,' cmd_migrate.c
  '';

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
      "UDEVLIBDIR=$out/lib/udev"
      "INITRAMFS_DIR=$TMPDIR"
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
