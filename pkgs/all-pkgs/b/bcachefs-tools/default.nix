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
  date = "2018-10-21";
  rev = "67fb317a0706ec3d305f4b02b3fa4b75717cd848";
in
stdenv.mkDerivation {
  name = "bcachefs-tools-${date}";

  src = fetchzip {
    version = 6;
    url = "https://evilpiepirate.org/git/bcachefs-tools.git/snapshot/bcachefs-tools-${rev}.tar.xz";
    multihash = "QmSBFrirXfgtSvpRiNTH3wrqVAMRESBZSmA7kVDtY4cG1S";
    sha256 = "49923eb0817cf3f8ea311680e77024882a508e77412708875d673aacfed7b9b5";
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
