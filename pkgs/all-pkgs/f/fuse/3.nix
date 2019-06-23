{ stdenv
, fetchurl
, meson
, ninja

, systemd-dummy
}:

stdenv.mkDerivation rec {
  name = "fuse-3.6.1";

  src = fetchurl {
    url = "https://github.com/libfuse/libfuse/releases/download/${name}/"
      + "${name}.tar.xz";
    hashOutput = false;
    sha256 = "6dc3b702f2d13187ff4adb8bcbdcb913ca0510ce0020e4d87bdeb4d794173704";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    systemd-dummy
  ];

  postPatch = ''
    # Don't build unecessary stuff
    echo -n "" | tee {example,doc,test}/meson.build

    # Fix hardcoded paths
    sed -i lib/mount_util.c \
      -e 's@\([" ]\)/bin/@\1/run/current-system/sw/bin/@g'

    # Can't chmod / chown in a nix-build
    sed -i 's,\(chmod\|chown\|mknod\|mkdir\),true,g' util/install_helper.sh
    sed -i "s,\".*/etc/init.d,\"$TMPDIR," util/install_helper.sh
    sed -i "s,/etc,$out/etc,g" util/install_helper.sh
  '';

  mesonFlags = [
    "-Dexamples=false"
  ];

  buildLTO = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "ED31 791B 2C5C 1613 AF38  8B8A D113 FCAC 3C4E 599F";
      };
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
