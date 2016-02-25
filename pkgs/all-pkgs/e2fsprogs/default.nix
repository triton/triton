{ stdenv
, fetchurl

, util-linux_lib
}:

stdenv.mkDerivation rec {
  name = "e2fsprogs-1.42.13";

  src = fetchurl {
    url = "mirror://sourceforge/e2fsprogs/${name}.tar.gz";
    sha256 = "1m72lk90b5i3h9qnmss6aygrzyn8x2avy3hyaq2fb0jglkrkz6ar";
  };

  buildInputs = [
    util-linux_lib
  ];

  configureFlags = [
    "--enable-symlink-install"
    "--enable-relative-symlinks"
    "--enable-symlink-relative-symlinks"
    "--disable-compression"
    "--enable-htree"
    "--enable-elf-shlibs"
    "--disable-profile"
    "--disable-gcov"
    "--disable-jbd-debug"
    "--disable-blkid-debug"
    "--disable-testio-debug"
    "--enable-libuuid"
    "--enable-libblkid"
    "--enable-quota"
    "--disable-backtrace"
    "--disable-debugfs"
    "--enable-imager"
    "--enable-resizer"
    "--enable-defrag"
    "--enable-fsck"
    "--disable-e2initrd-helper"
    "--enable-tls"
    "--disable-uuidd"  # Build is broken in 1.42.13
  ];

  installFlags = [
    "LN=ln -s"
  ];

  installTargets = [
    "install"
    "install-libs"
  ];

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
