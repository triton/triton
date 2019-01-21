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
  date = "2019-01-14";
  rev = "8630059e6ac363bea39e54df3f8115da5a5c2c5d";
in
stdenv.mkDerivation {
  name = "bcachefs-tools-${date}";

  src = fetchzip {
    version = 6;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-${rev}.tar.xz";
    multihash = "QmZ55yYDPRW9ZhH8doR5LqDWrWFJmBBYrTZKdBWNPdj5Xh";
    sha256 = "ad8f6433a18fa8525499ea4cb1a97fa008653ab3aeaf7b43022c03300f2e55a2";
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
