{ stdenv
, fetchurl

, gnutls
, libgcrypt
, util-linux_full
}:

stdenv.mkDerivation rec {
  pname = "ntfs-3g";
  version = "2016.2.22";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://tuxera.com/opensource/ntfs-3g_ntfsprogs-${version}.tgz";
    sha256 = "d7b72c05e4b3493e6095be789a760c9f5f2b141812d5b885f3190c98802f1ea0";
  };

  buildInputs = [
    gnutls
    libgcrypt
    util-linux_full
  ];

  patchPhase = ''
    substituteInPlace src/Makefile.in --replace /sbin '@sbindir@'
    substituteInPlace ntfsprogs/Makefile.in --replace /sbin '@sbindir@'
    substituteInPlace libfuse-lite/mount_util.c \
      --replace /bin/mount ${util-linux_full}/bin/mount \
      --replace /bin/umount ${util-linux_full}/bin/umount
  '';

  configureFlags = [
    "--disable-ldconfig"
    "--exec-prefix=\${prefix}"
    "--enable-mount-helper"
    "--enable-posix-acls"
    "--enable-xattr-mappings"
    "--enable-crypto"
  ];

  postInstall = ''
    # Prefer ntfs-3g over the ntfs driver in the kernel.
    ln -sv mount.ntfs-3g $out/sbin/mount.ntfs
  '';

  meta = with stdenv.lib; {
    homepage = http://www.tuxera.com/community/;
    description = "FUSE-based NTFS driver with full write support";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

