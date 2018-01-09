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

  version = "4.14.0";
in
stdenv.mkDerivation rec {
  name = "xfsprogs-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") (tarballUrls version);
    hashOutput = false;
    sha256 = "b1b710b268bc95d6f45eca06e1262c29eb38865a19cd4404e48ba446e043b7ec";
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
    grep -q '/bin/bash' install-sh
    sed -i "s,/bin/bash,$(type -P bash),g" install-sh
    sed -i "s,ldconfig,$(type -P ldconfig),g" configure m4/libtool.m4

    # Fixes from gentoo 3.2.1 ebuild
    sed -i "/^PKG_DOC_DIR/s:@pkg_name@:${name}:" include/builddefs.in
    sed -i "/LLDFLAGS.*libtool-libs/d" $(find -name Makefile)
    sed -i '/LIB_SUBDIRS/s:libdisk::' Makefile
  '';

  patches = [
    (fetchTritonPatch {
      rev = "185665e99c148594758a4f22346ad4d3c6cbbb5d";
      file = "x/xfsprogs/0001-xfsprogs-4.12.0-sharedlibs.patch";
      sha256 = "4f10b622e8b7c8654a5dc79356343515ef203742ba4781b97a6f02f23e99555a";
    })
    (fetchTritonPatch {
      rev = "185665e99c148594758a4f22346ad4d3c6cbbb5d";
      file = "x/xfsprogs/0002-xfsprogs-4.9.0-underlinking.patch";
      sha256 = "644713208fcce550cbe66de8aa3fc366449a838baaba2db030bfc6111f4de7b5";
    })
    (fetchTritonPatch {
      rev = "185665e99c148594758a4f22346ad4d3c6cbbb5d";
      file = "x/xfsprogs/0003-xfsprogs-4.7.0-libxcmd-link.patch";
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

  installParallel = false;

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
