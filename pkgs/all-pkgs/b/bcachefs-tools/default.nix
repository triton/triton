{ stdenv
, fetchzip
, lib

, keyutils
, libaio
, libscrypt
, libsodium
, liburcu
, lz4
, util-linux_lib
, zlib
, zstd
}:

let
  date = "2019-01-23";
  rev = "35fca2f044d375b1590f499cfd34bef38ca0f8f1";
in
stdenv.mkDerivation {
  name = "bcachefs-tools-${date}";

  src = fetchzip {
    version = 6;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-${rev}.tar.xz";
    multihash = "QmW94u4GrnLMKKvL6PLBFEDP8jQeDgvC42oxTJrZFy237V";
    sha256 = "d62d6cc9d869a926e6f64b5fa09d0063cd78050ca0df1ab5b92244528f9b912a";
  };

  buildInputs = [
    keyutils
    libaio
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

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
