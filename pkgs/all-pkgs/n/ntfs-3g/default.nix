{ stdenv
, fetchurl

, gnutls
, libgcrypt
, util-linux_full
}:

let
  version = "2017.3.23";
in
stdenv.mkDerivation rec {
  name = "ntfs-3g-${version}";

  src = fetchurl {
    url = "https://tuxera.com/opensource/ntfs-3g_ntfsprogs-${version}.tgz";
    multihash = "QmcwE57BBCRdzyQwDwREnXcTtu33eGbH4cL1v1VGceX9Up";
    sha256 = "3e5a021d7b761261836dcb305370af299793eedbded731df3d6943802e1262d5";
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
    "--enable-extras"
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

