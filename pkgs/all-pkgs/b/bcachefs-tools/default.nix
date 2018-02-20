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
  date = "2018-02-19";
  rev = "cdf17bffadb3346ea4424357b5bb85de852231e9";
in
stdenv.mkDerivation {
  name = "bcache-tools-${date}";

  src = fetchzip {
    version = 5;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-${rev}.tar.xz";
    multihash = "QmRxbVJY89HFw9qLpUXfLhwb2bPmK77bB2YDW3BvFGTc5Q";
    sha256 = "e091e66afede0fcec84537ae14d37b3a12148778680c41c6e019d0a2135b9e57";
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
