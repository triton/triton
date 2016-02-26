{ stdenv
, fetchurl
, util-linux_full
, libgcrypt
, gnutls
}:

stdenv.mkDerivation rec {
  pname = "ntfs-3g";
  version = "2015.3.14";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "http://tuxera.com/opensource/ntfs-3g_ntfsprogs-${version}.tgz";
    sha256 = "1wiqcmy07y02k3iqq56cscnhg5syisbjj9mxfaid85l3bl0rdycp";
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

  postInstall =
    ''
      # Prefer ntfs-3g over the ntfs driver in the kernel.
      ln -sv mount.ntfs-3g $out/sbin/mount.ntfs
    '';

  meta = with stdenv.lib; {
    homepage = http://www.tuxera.com/community/;
    description = "FUSE-based NTFS driver with full write support";
    maintainers = [ maintainers.urkud ];
    platforms = platforms.linux;
    license = licenses.gpl2Plus; # and (lib)fuse-lite under LGPL2+
  };
}

