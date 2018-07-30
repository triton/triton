{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "fuse-2.9.8";

  src = fetchurl {
    url = "https://github.com/libfuse/libfuse/releases/download/${name}/"
      + "${name}.tar.gz";
    hashOutput = false;
    sha256 = "5e84f81d8dd527ea74f39b6bc001c874c02bad6871d7a9b0c14efb57430eafe3";
  };

  postPatch = ''
    sed -i lib/mount_util.c \
      -e 's@\([" ]\)/bin/@\1/run/current-system/sw/bin/@g'
  '';

  preConfigure = ''
    export MOUNT_FUSE_PATH="$out"/bin
    export INIT_D_PATH="$TMPDIR"
    export UDEV_RULES_PATH="$out"/etc/udev/rules.d
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
