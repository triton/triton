{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "fuse-2.9.5";
  
  src = fetchurl {
    url = "https://github.com/libfuse/libfuse/releases/download/${stdenv.lib.replaceStrings ["-" "."] ["_" "_"] name}/${name}.tar.gz";
    sha256 = "579f371cc5ffc1afca7057512bf7d52988a9ede57859a7c55e5b9f72435cdbb5";
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
