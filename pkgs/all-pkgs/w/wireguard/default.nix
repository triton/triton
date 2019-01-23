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

  rev = "40eaf20e04eed44e226fc41bc8e8b159467a7399";
  date = "2019-01-23";
in
stdenv.mkDerivation {
  name = "wireguard-${date}${optionalString (kernel != null) "-${kernel.version}"}";

  src = fetchzip {
    version = 6;
    url = "https://git.zx2c4.com/WireGuard/snapshot/WireGuard-${rev}.tar.xz";
    multihash = "Qmau9DwH6TDUUidcSVwwffVnnqnDY1KnfRh1yv5rJD5xmT";
    sha256 = "0ca2e9ffa4ef1fe8a8b23b92063ec41557f0208464bc60943b7080036ab467ed";
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
