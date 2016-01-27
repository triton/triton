{ stdenv
, fetchTritonPatch
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "cdparanoia-III-10.2";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/cdparanoia/${name}.src.tgz";
    sha256 = "1pv4zrajm46za0f6lv162iqffih57a8ly4pc69f7y0gfyigb8p80";
  };

  patches = [
    (fetchTritonPatch {
      rev = "7bcbe0475f1bf0af301b7357473ff2b92a3cf226";
      file = "cdparanoia/010_all_build_system.patch";
      sha256 = "85c8f89a6c9c29e219c4b4a0a18f904633b01e3883c622b04bb5de89761a6f0e";
    })
    (fetchTritonPatch {
      rev = "7bcbe0475f1bf0af301b7357473ff2b92a3cf226";
      file = "cdparanoia/020_all_include_cdda_interface_h.patch";
      sha256 = "5487862c06dd026844ed046ca8a8d3a1532890407c5ff78378cceb68d179efec";
    })
    (fetchTritonPatch {
      rev = "7bcbe0475f1bf0af301b7357473ff2b92a3cf226";
      file = "cdparanoia/030_all_big_endian.patch";
      sha256 = "c061cfd152e0553384ce174232a9aac345c22adec69c810958008f60c57e8d90";
    })
    (fetchTritonPatch {
      rev = "7bcbe0475f1bf0af301b7357473ff2b92a3cf226";
      file = "cdparanoia/040_all_gcc43.patch";
      sha256 = "9bd7a689528d32933fa38a6c0490716277174d59974ac23f96852517242c4ab3";
    })
    (fetchTritonPatch {
      rev = "7bcbe0475f1bf0af301b7357473ff2b92a3cf226";
      file = "cdparanoia/050_all_build_only_shared_libraries.patch";
      sha256 = "d105e8325845bde5da756594824225d7b020abda1c27824c848f2bf0056339a3";
    })
  ];

  preConfigure = "unset CC";

  meta = with stdenv.lib; {
    description = "An advanced CDDA reader with error correction";
    homepage = http://xiph.org/paranoia;
    license = with licenses; [
      gpl2
      lgpl21
    ];
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
