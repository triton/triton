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
  date = "2018-08-22";
  rev = "ebf97e8e01a8e76ff4bec23f29106430852c3081";
in
stdenv.mkDerivation {
  name = "bcachefs-tools-${date}";

  src = fetchzip {
    version = 6;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-${rev}.tar.xz";
    multihash = "QmNvLg39CHpz156pbfGtejGFktR9ro1Ciy6uWb1ZD4B29B";
    sha256 = "8d93d577d55060aaeb3df6e549cf83ad202691bc5aaa7f9584509c65cda5211b";
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
