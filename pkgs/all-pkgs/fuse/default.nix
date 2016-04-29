{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "fuse-2.9.6";
  
  src = fetchurl {
    url = "https://github.com/libfuse/libfuse/releases/download/${name}/${name}.tar.gz";
    allowHashOutput = false;
    sha256 = "0cb48bbc7106632d15a0c6bb582496c9884b869e329428891fe075a9e916f16b";
  };

  preConfigure = ''
    export MOUNT_FUSE_PATH=$out/sbin
    export INIT_D_PATH=$out/etc/init.d
    export UDEV_RULES_PATH=$out/etc/udev/rules.d
    export NIX_CFLAGS_COMPILE="-DFUSERMOUNT_DIR=\"/no-such-path\""
  '';

  preBuild = ''
    sed -e 's@/bin/@/run/current-system/sw/bin/@g' -i lib/mount_util.c
  '';

  configureFlags = [
    "--disable-kernel-module"
  ];

  passthru = {
    srcVerified = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "ED31 791B 2C5C 1613 AF38  8B8A D113 FCAC 3C4E 599F";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://fuse.sourceforge.net/;
    description = "Kernel module and library that allows filesystems to be implemented in user space";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
