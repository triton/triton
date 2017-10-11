{ stdenv
, fetchzip

, kernel
, libmnl
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;

  rev = "27a07f7e6544a0aede2260a2ff4a7acf5308d0f0";
  date = "2017-10-11";
in
stdenv.mkDerivation {
  name = "wireguard-${date}${optionalString (kernel != null) "-${kernel.version}"}";

  src = fetchzip {
    version = 3;
    url = "https://git.zx2c4.com/WireGuard/snapshot/WireGuard-${rev}.tar.xz";
    multihash = "QmYr6uU4n4r2sf7iVp26YusMRNtZ5BcEDEX3L67buYD3Ys";
    sha256 = "776f2694809cda3959680938db2d49585c1d216a0fc7f517df632a48d1bf9bcc";
  };

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
