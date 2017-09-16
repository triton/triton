{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "fuse-2.9.7";

  src = fetchurl {
    url = "https://github.com/libfuse/libfuse/releases/download/${name}/"
      + "${name}.tar.gz";
    hashOutput = false;
    sha256 = "832432d1ad4f833c20e13b57cf40ce5277a9d33e483205fc63c78111b3358874";
  };

  preConfigure = ''
    export MOUNT_FUSE_PATH=$out/sbin
    export INIT_D_PATH=$out/etc/init.d
    export UDEV_RULES_PATH=$out/etc/udev/rules.d
  '';

  preBuild = ''
    sed -i lib/mount_util.c \
      -e 's@/bin/@/run/current-system/sw/bin/@g'
  '';

  configureFlags = [
    "--enable-lib"
    "--enable-util"
    "--disable-example"
    "--disable-mtab"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "ED31 791B 2C5C 1613 AF38  8B8A D113 FCAC 3C4E 599F";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Kernel module and library for filesystems in user space";
    homepage = http://fuse.sourceforge.net/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
