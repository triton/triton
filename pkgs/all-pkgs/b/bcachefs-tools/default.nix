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
  date = "2019-03-02";
  rev = "70bb5ab7a863ccff57ceb2a195d7cfa0fdf39218";
in
stdenv.mkDerivation {
  name = "bcachefs-tools-${date}";

  src = fetchzip {
    version = 6;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-${rev}.tar.xz";
    multihash = "Qma5UV4wSw6t7T8mCUTD6ECRiVbrGAV2Wcf4v6F1xgWazu";
    sha256 = "6f9014ccd9cacb2f7e9d4922073ada867b924a59507c2449c253c1f0c6fcb7cb";
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
