{ stdenv
, fetchTritonPatch
, fetchurl

, channel
}:

let
  sources = import ./sources.nix;

  inherit (sources."${channel}")
    sha256
    version;

  inherit (stdenv.lib)
    optionals
    versionAtLeast;
in
stdenv.mkDerivation rec {
  name = "fuse-${version}";

  src = fetchurl {
    url = "https://github.com/libfuse/libfuse/releases/download/${name}/"
      + "${name}.tar.gz";
    hashOutput = false;
    inherit sha256;
  };

  patches = optionals (channel == "3") [
    (fetchTritonPatch {
      rev = "fc9cab71a5192c898889e092affbf1b36a19c093";
      file = "f/fuse/fix-3.1.0.patch";
      sha256 = "b90bbce0e6b9a721ac91ee8f19f8902d4c6e85d68140363494025a19dfc472bd";
    })
  ];

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
  ] ++ optionals (versionAtLeast version "3.0.0") [
    "--disable-test"
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
