{ stdenv
, elfutils
, fetchzip
, perl

, kernel
, libmnl
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;

  rev = "d8179bf1ed9ecf0c7f9a78ceb0566a7e7b2f4497";
  date = "2019-07-02";
in
stdenv.mkDerivation {
  name = "wireguard-${date}${optionalString (kernel != null) "-${kernel.version}"}";

  src = fetchzip {
    version = 6;
    url = "https://git.zx2c4.com/WireGuard/snapshot/WireGuard-${rev}.tar.xz";
    multihash = "QmbAVXRjSFo5eHwrzaVBj5SRMnezCoLpER18C7FRRWx6hM";
    sha256 = "a3ebfed73a6506a6e4f61cd6d46b86bb9e6abab42dad819e5bcb3ca576b583b8";
  };

  nativeBuildInputs = optionals (kernel != null) [
    elfutils
    perl
  ];

  buildInputs = optionals (kernel == null) [
    libmnl
  ];

  preConfigure = ''
    cd src
  '';

  makeFlags = if kernel != null then [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ] else [
    "-C"
    "tools"
  ];

  buildFlags = optionals (kernel != null) [
    "modules"
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '' + optionalString (kernel != null) ''
    makeFlagsArray+=(
      "M=$(pwd)"
      "INSTALL_MOD_PATH=$out"
      "INSTALL_MOD_STRIP=1"
    )
  '';

  installTargets = optionals (kernel != null) [
    "modules_install"
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
