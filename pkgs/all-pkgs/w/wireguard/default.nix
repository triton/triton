{ stdenv
, elfutils
, fetchzip

, kernel
, libmnl
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;

  rev = "393d8f2fcb61ed677dae9459c43858e37f1bd30d";
  date = "2018-08-09";
in
stdenv.mkDerivation {
  name = "wireguard-${date}${optionalString (kernel != null) "-${kernel.version}"}";

  src = fetchzip {
    version = 6;
    url = "https://git.zx2c4.com/WireGuard/snapshot/WireGuard-${rev}.tar.xz";
    multihash = "QmTmq4T2s6ortdhAN8UZUEuYd4tKsbUYKvfK9JA3LpJfxi";
    sha256 = "c51052d19be74532f354c16934a666481f4eaff72f691c4eb82f9e348447c07a";
  };

  nativeBuildInputs = optionals (kernel != null) [
    elfutils
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
