{ stdenv
, bc
, elfutils
, fetchzip
, perl

, kernel
}:

let
  rev = "d05a993b76af758b4bd998999aea633d30e88ce4";
  date = "2020-02-15";
in
stdenv.mkDerivation {
  name = "wireguard-linux-compat-${date}-${kernel.version}";

  src = fetchzip {
    version = 6;
    url = "https://git.zx2c4.com/wireguard-linux-compat/snapshot/wireguard-linux-compat-${rev}.tar.xz";
    multihash = "QmQxbVPTAYtiMem2YuXoQ1i58E7eGfM93h5oiTqA5iJzEo";
    sha256 = "2d95351d5f7efa5deef7839c89c6816bb0e2ca19afc37c798ed8ce898d88306a";
  };

  nativeBuildInputs = [
    bc
    elfutils
    perl
  ];

  preConfigure = ''
    cd src
  '';

  makeFlags = [
    "DEPMOD=true"
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "PREFIX=${placeholder "out"}"
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "INSTALL_MOD_STRIP=1"
  ];

  # Kernel code doesn't support our hardening flags
  optFlags = kernel == null;
  pie = kernel == null;
  fpic = kernel == null;
  noStrictOverflow = kernel == null;
  fortifySource = kernel == null;
  stackProtector = kernel == null;
  optimize = kernel == null;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
