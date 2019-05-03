{ stdenv
, fetchgit
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
  date = "2019-04-17";
  rev = "b485aae1bac95e3b5be235116e2bc43da85906c5";
in
stdenv.mkDerivation {
  name = "bcachefs-tools-${date}";

  src = fetchgit {
    version = 6;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git";
    inherit rev;
    multihash = "QmZRyPV5mvLRRtrmq2LjVvfCvzjZVipyYbBUzr4CPB4d5a";
    sha256 = "f79ae1a6d4186b3157fb593cbb9b4c72efd0b412b5c2bbc07d4d31240b63f328";
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
