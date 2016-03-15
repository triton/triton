{ stdenv
, fetchTritonPatch
, fetchurl

, mp4v2

# Digital Radio Mondiale
, drmSupport ? false
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "faac-${version}";
  version = "1.28";

  src = fetchurl {
    url = "mirror://sourceforge/faac/${name}.tar.gz";
    sha256 = "1pqr7nf6p2r283n0yby2czd3iy159gz8rfinkis7vcfgyjci2565";
  };

  buildInputs = [
    mp4v2
  ];

  patches = [
    (fetchTritonPatch {
      rev = "11df088db92a272a4a8eef4fd3883812d05dcdc4";
      file = "faac/faac-1.28-external-libmp4v2.patch";
      sha256 = "8e0bfe501acb7f31a701ab2c797c2ace539ccd60e5f5b3c0ae538bcd5719c1df";
    })
    (fetchTritonPatch {
      rev = "11df088db92a272a4a8eef4fd3883812d05dcdc4";
      file = "faac/faac-1.28-altivec.patch";
      sha256 = "6e836dc6cb5967a17f24cc236938452714b814a26a556d39d0a08a307835691a";
    })
    (fetchTritonPatch {
      rev = "11df088db92a272a4a8eef4fd3883812d05dcdc4";
      file = "faac/faac-1.28-libmp4v2_r479_compat.patch";
      sha256 = "6d18ff5f5ad8e7e1717a7afcf5c7465637fc8866a213aeba44f5448de8e2ce8b";
    })
    (fetchTritonPatch {
      rev = "11df088db92a272a4a8eef4fd3883812d05dcdc4";
      file = "faac/faac-1.28-inttypes.patch";
      sha256 = "9ab0e1eb8f489012e07a59c7ca8129b2a962fabdba7a1194155a68c7321070be";
    })
  ];

  postPatch =
    /* Fix reference to obsolete macro */ ''
      sed -i configure.in \
        -e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:'
    '';

  configureFlags = [
    (enFlag "drm" drmSupport null)
    "--enable-largefile"
    (wtFlag "mp4v2" (mp4v2 != null) null)
  ];

  meta = with stdenv.lib; {
    description = "Open source MPEG-4 and MPEG-2 AAC encoder";
    homepage = http://www.audiocoding.com/faac.html;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
