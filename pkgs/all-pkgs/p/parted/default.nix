{ stdenv
, fetchTritonPatch
, fetchurl

, libselinux
, libsepol
, lvm2
, ncurses
, readline
, util-linux_lib
}:

stdenv.mkDerivation rec {
  name = "parted-3.2";

  src = fetchurl {
    url = "mirror://gnu/parted/${name}.tar.xz";
    hashOutput = false;
    sha256 = "1r3qpg3bhz37mgvp9chsaa3k0csby3vayfvz8ggsqz194af5i2w5";
  };

  buildInputs = [
    libselinux
    libsepol
    lvm2
    ncurses
    readline
    util-linux_lib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "2885317c1a4e726b77997a04b68c24530b521daf";
      file = "p/parted/fix-fat16-crash.patch";
      sha256 = "3cbf31765b1653609a4c95687b91e34dd57ad3498d5d02019c966bd46d25d100";
    })
    (fetchTritonPatch {
      rev = "223472dcdececc27633295ca3cb29e4a37f3640a";
      file = "p/parted/glibc-2.27.patch";
      sha256 = "789d6ef8fcff389f9f74bd9e377aff9949ab5b317a80bd38cec39510bd40cef6";
    })
  ];

  configureFlags = [
    "--enable-device-mapper"
    "--enable-selinux"
    "--enable-dynamic-loading"
    "--disable-debug"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "1B49 F933 916A 37A3 F45A  1812 015F 4DD4 A70F B705";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Create, destroy, resize, check, and copy partitions";
    homepage = http://www.gnu.org/software/parted/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
