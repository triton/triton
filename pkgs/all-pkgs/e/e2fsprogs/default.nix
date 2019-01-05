{ stdenv
, fetchurl

, fuse_2
, util-linux_lib
}:

let
  version = "1.44.5";
in
stdenv.mkDerivation rec {
  name = "e2fsprogs-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/e2fsprogs/e2fsprogs/v${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "2e211fae27ef74d5af4a4e40b10b8df7f87c655933bd171aab4889bfc4e6d1cc";
  };

  buildInputs = [
    fuse_2
    util-linux_lib
  ];

  configureFlags = [
    "--enable-symlink-install"
    "--enable-relative-symlinks"
    "--enable-elf-shlibs"
    "--disable-profile"
    "--disable-gcov"
    "--enable-hardening"
    "--disable-jbd-debug"
    "--disable-blkid-debug"
    "--disable-testio-debug"
    "--disable-libuuid"
    "--disable-libblkid"
    "--disable-backtrace"
    "--enable-debugfs"
    "--enable-imager"
    "--enable-resizer"
    "--enable-defrag"
    "--enable-fsck"
    "--disable-e2initrd-helper"
    "--enable-tls"
    "--disable-uuidd"  # Broken in 1.44.0
    "--enable-mmp"
    "--enable-tdb"
    "--enable-bmap-stats"
    "--enable-bmap-stats-ops"
    "--enable-fuse2fs"
  ];

  installTargets = [
    "install"
    "install-libs"
  ];

  # Parallel install is broken
  installParallel = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "3AB0 57B7 E78D 945C 8C55  91FB D36F 769B C118 04F0";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "Tools for creating and checking ext2/ext3/ext4 filesystems";
    homepage = http://e2fsprogs.sourceforge.net/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
