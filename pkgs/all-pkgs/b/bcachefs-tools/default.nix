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
  date = "2019-05-29";
  rev = "34b93747051055c1076add36f4730c7715e27f07";
in
stdenv.mkDerivation {
  name = "bcachefs-tools-${date}";

  src = fetchgit {
    version = 6;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git";
    inherit rev;
    multihash = "Qmb1BP53Sx5x4FeWLZofk5htaczYiY18dyAJTfV93FJCaH";
    sha256 = "efa202c86053941058d2bca77480ad6b6a83b7cee42f4e362abbae6e9985cbe0";
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
