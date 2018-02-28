{ stdenv
, fetchTritonPatch
, fetchurl
, gettext

, attr
, libunistring
, readline
, util-linux_lib
}:

let
  tarballUrls = version: [
    "mirror://kernel/linux/utils/fs/xfs/xfsprogs/xfsprogs-${version}.tar"
  ];

  version = "4.15.1";
in
stdenv.mkDerivation rec {
  name = "xfsprogs-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") (tarballUrls version);
    hashOutput = false;
    sha256 = "27c36de9346a274143ad06c65b2fdbafd2806f3f37fa2c1235a08ed920d2bf3c";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    attr
    libunistring
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

    # Remove static
    find . -name Makefile -exec sed -i 's, -static,,g' {} \;

    # Don't link against libtool-libs
    find . -name Makefile -exec sed -i 's,=-libtool-libs,=,g' {} \;

    # Don't depend on shared libs
    find . -name Makefile -exec sed -i '/^LTDEPENDENCIES/s, $(LIB\(RT\|UNISTRING\)),,g' {} \;
  '';

  patches = [
    (fetchTritonPatch {
      rev = "7231d726f6b0e134ce4c02dce5cd9ebf47d6138c";
      file = "x/xfsprogs/0001-xfsprogs-4.9.0-underlinking.patch";
      sha256 = "644713208fcce550cbe66de8aa3fc366449a838baaba2db030bfc6111f4de7b5";
    })
    (fetchTritonPatch {
      rev = "7231d726f6b0e134ce4c02dce5cd9ebf47d6138c";
      file = "x/xfsprogs/0002-xfsprogs-4.15.0-sharedlibs.patch";
      sha256 = "f3e3c00c92e4713fcfdbfa7a24b088f28352e4bd572b0ac9982d96d7b520da0b";
    })
    (fetchTritonPatch {
      rev = "7231d726f6b0e134ce4c02dce5cd9ebf47d6138c";
      file = "x/xfsprogs/0003-xfsprogs-4.15.0-docdir.patch";
      sha256 = "d935b4c5ddc52f6b49952a1f18f828f05de544baf8f2e66a066a0abc5b6c2feb";
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
