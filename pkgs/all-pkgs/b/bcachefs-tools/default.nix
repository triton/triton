{ stdenv
, fetchzip

, attr
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
  date = "2018-05-17";
  rev = "62e4df2a38081f62fd1bd657459b7ffb2d4f522c";
in
stdenv.mkDerivation {
  name = "bcachefs-tools-${date}";

  src = fetchzip {
    version = 6;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-${rev}.tar.xz";
    multihash = "QmTEP2JvyQ5VFDj9QVarucdau4Nz5z4xQRRWPUXjVQGqii";
    sha256 = "acef2beee0038fa71b648d67a7499e79eb81cf2e016d4eef184cfaebd3de3627";
  };

  buildInputs = [
    attr
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
