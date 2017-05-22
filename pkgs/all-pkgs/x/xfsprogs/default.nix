{ stdenv
, fetchTritonPatch
, fetchurl
, gettext

, readline
, util-linux_lib
}:

let
  tarballUrls = version: [
    "mirror://kernel/linux/utils/fs/xfs/xfsprogs/xfsprogs-${version}.tar"
  ];

  version = "4.11.0";
in
stdenv.mkDerivation rec {
  name = "xfsprogs-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") (tarballUrls version);
    hashOutput = false;
    sha256 = "c3a6d87b564d7738243c507df82276bed982265e345363a95f2c764e8a5f5bb2";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    readline
    util-linux_lib
  ];

  outputs = [
    "out"
    "lib"
  ];

  prePatch = ''
    sed -i "s,/bin/bash,$(type -P bash),g" install-sh
    sed -i "s,ldconfig,$(type -P ldconfig),g" configure m4/libtool.m4

    # Fixes from gentoo 3.2.1 ebuild
    sed -i "/^PKG_DOC_DIR/s:@pkg_name@:${name}:" include/builddefs.in
    sed -i "/LLDFLAGS.*libtool-libs/d" $(find -name Makefile)
    sed -i '/LIB_SUBDIRS/s:libdisk::' Makefile
  '';

  patches = [
    (fetchTritonPatch {
      rev = "f2cc828cd4a47b008b7503974f35bcdd2a9c74b3";
      file = "xfsprogs/xfsprogs-4.7.0-sharedlibs.patch";
      sha256 = "983b08b2a4a4ee91be21f14063167a3752554b41fd78aead6dfd6ac38702a5a7";
    })
    (fetchTritonPatch {
      rev = "f2cc828cd4a47b008b7503974f35bcdd2a9c74b3";
      file = "xfsprogs/xfsprogs-4.7.0-libxcmd-link.patch";
      sha256 = "06cced4aeeb9a2d8c90e6d6fd1ff6571020122dbfe62140513f52bd82bf9abe8";
    })
  ];

  preConfigure = ''
    NIX_LDFLAGS="$(echo $NIX_LDFLAGS | sed "s,$out,$lib,g")"
  '';

  configureFlags = [
    "MAKE=make"
    "MSGFMT=msgfmt"
    "MSGMERGE=msgmerge"
    "XGETTEXT=xgettext"
    "--disable-lib64"
    "--enable-readline"
    "--includedir=$(lib)/include"
    "--libdir=$(lib)/lib"
  ];

  installFlags = [
    "install-dev"
  ];

  parallelInstall = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrl = map (n: "${n}.sign") (tarballUrls version);
      pgpKeyFingerprints = [
        # Dave Chinner
        "9893 A827 C19F 7D96 164A  38FF ADE8 2947 F475 FA1D"
        # Eric R. Sandeen
        "2B81 8591 9E8D 2489 8186  9DED 20AE 1692 E13D DEE0"
      ];
      failEarly = true;
      pgpDecompress = true;
    };
  };

  meta = with stdenv.lib; {
    description = "SGI XFS utilities";
    homepage = http://xfs.org/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
