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
, zstd
}:

let
  date = "2018-03-13";
  rev = "33d0a49489c60df4df924bfbc0c7ad98a11dd3ed";
in
stdenv.mkDerivation {
  name = "bcache-tools-${date}";

  src = fetchzip {
    version = 5;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-${rev}.tar.xz";
    multihash = "QmNhioXbL2mAvZAwK1rkGCmEbQVvAnoSyThofNVtbuyiza";
    sha256 = "db5ee086a4bfe2017a6e65d3d3a32c075214f74f9ddcb005e63555b8aa02c0fb";
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
    zstd
  ];

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
