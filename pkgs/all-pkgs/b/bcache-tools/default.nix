{ stdenv
, fetchTritonPatch
, fetchzip
, lib

, libnih
, util-linux_lib
}:

let
  version = "1.0.8";
in
stdenv.mkDerivation rec {
  name = "bcache-tools-${version}";

  src = fetchzip {
    version = 2;
    url = "https://evilpiepirate.org/git/bcache-tools.git/snapshot/v${version}.tar.xz";
    multihash = "QmUnHv2sXFLVN3R7tHvr3iHMGRJfF7h9F9Rg5ZxbwZiXnA";
    sha256 = "36f775d77d452f756eac9a8117b7421e5606457d81c6d736868db8f6974f60d3";
  };

  buildInputs = [
    libnih
    util-linux_lib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "1819d2675437afe29d58dd4bf3aa339819a2f62d";
      file = "b/bcache-tools/0001-Fix-static-crc64.patch";
      sha256 = "063f0695ce06c4a0476e813e8951ccd45e423f9178538baf12fc5eb7ac1df72a";
    })
    (fetchTritonPatch {
      rev = "1819d2675437afe29d58dd4bf3aa339819a2f62d";
      file = "b/bcache-tools/0002-Disable-unneeded-installed-items.patch";
      sha256 = "b74eb87d213187d01c809d2f62a59c760e75bb337b33b715dd256aae56c0c9a0";
    })
  ];

  postPatch = ''
    sed -i '/-static/d' Makefile
  '';

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
      "UDEVLIBDIR=$out/lib/udev"
    )
  '';

  preInstall = ''
    mkdir -p "$out/bin"
    mkdir -p "$out/sbin"
    mkdir -p "$out/share/man/man8"
    mkdir -p "$out/lib/udev/rules.d"
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
