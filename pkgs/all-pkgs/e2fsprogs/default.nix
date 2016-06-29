{ stdenv
, fetchurl

, fuse
, util-linux_lib
}:

let
  version = "1.43.1";
  name = "e2fsprogs-${version}";

  baseTarballs = [
    "mirror://kernel/linux/kernel/people/tytso/e2fsprogs/v${version}/${name}.tar"
    "mirror://sourceforge/e2fsprogs/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.xz") baseTarballs;
    allowHashOutput = false;
    sha256 = "97e36a029224e2606baa6e9ea693b04a4d192ccd714572a1b50a2df9c687b23d";
  };

  buildInputs = [
    fuse
    util-linux_lib
  ];

  configureFlags = [
    "--enable-symlink-install"
    "--enable-relative-symlinks"
    "--enable-symlink-relative-symlinks"
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
    "--disable-debugfs"
    "--enable-imager"
    "--enable-resizer"
    "--enable-defrag"
    "--enable-fsck"
    "--disable-e2initrd-helper"
    "--enable-tls"
    "--disable-uuidd"  # Build is broken in 1.43.1
    "--enable-mmp"
    "--enable-tdb"
    "--enable-bmap-stats"
    "--enable-bmap-stats-ops"
    "--enable-fuse2fs"
  ];

  installFlags = [
    "LN=ln -s"
  ];

  installTargets = [
    "install"
    "install-libs"
  ];

  # Parallel install is broken
  parallelInstall = false;

  passthru = {
    srcVerified = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sign") baseTarballs;
      pgpDecompress = true;
      pgpKeyFingerprint = "3AB0 57B7 E78D 945C 8C55  91FB D36F 769B C118 04F0";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };


  meta = with stdenv.lib; {
    homepage = http://e2fsprogs.sourceforge.net/;
    description = "Tools for creating and checking ext2/ext3/ext4 filesystems";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
