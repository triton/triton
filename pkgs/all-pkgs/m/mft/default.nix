{ stdenv
, fetchurl

, kernel
}:

let
  version = "4.6.0-48";

  urls' = arch: [
    "http://www.mellanox.com/downloads/MFT/mft-${version}-${arch}.tgz"
  ];

  sources = {
    "x86_64-linux" = {
      urls = urls' "x86_64-deb";
      md5Confirm = "637ad04bb1c19e25aa811e7782679da0";
      sha256 = "253777450f2c6b04e85cacc14acc14d59bd335f2cd9ebdc272c2c01e5b89c8e2";
    };
  };

  uarches = {
    "x86_64-linux" = "x86_64";
  };

  inherit (stdenv.lib)
    optionals
    optionalString;

  inherit (sources."${stdenv.targetSystem}")
    urls
    md5Confirm
    sha256;
in
stdenv.mkDerivation rec {
  name = "mft-${version}${optionalString (kernel != null) "-${kernel.version}"}";

  src = fetchurl {
    inherit urls md5Confirm sha256;
  };

  preBuild = optionalString (kernel != null) ''
    ar vx SDEBS/*
    tar xf data.tar.gz

    cd usr/src/*
    cat Makefile

    makeFlagsArray+=("INSTALL_MOD_PATH=$out")
  '';

  makeFlags = optionals (kernel != null) [
    "KPVER=${kernel.modDirVersion}"
    "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "CPU_ARCH=${uarches."${stdenv.targetSystem}"}"
  ];

  buildPhase = optionalString (kernel == null) ''
    ar vx DEBS/${name}*
    tar xf data.tar.gz

    rm usr/bin/mst
    mv etc/init.d/mst usr/bin
    rmdir etc/init.d

    for file in $(echo usr/bin/*); do
      echo "$(basename "$file"): Checking if ELF" >&2
      if readelf -h "$file" >/dev/null 2>&1; then
        echo "$(basename "$file"): Patching" >&2
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${stdenv.cc.cc}/lib" "$file"
      fi
    done
  '';

  installPhase = optionalString (kernel == null) ''
    mkdir -p "$out"
    mv etc usr/{bin,share} "$out"
  '' + optionalString (kernel != null) ''
    modDir="$out/lib/modules/${kernel.modDirVersion}/extra"
    mkdir -p "$modDir"
    for module in $(find . -name \*.ko); do
      xz -9 -c "$module" >"$modDir/$(basename "$module").xz"
    done
  '';

  # Kernel code doesn't support our hardening flags
  optFlags = kernel == null;
  pie = kernel == null;
  fpic = kernel == null;
  noStrictOverflow = kernel == null;
  fortifySource = kernel == null;
  stackProtector = kernel == null;
  optimize = kernel == null;

  # Binaries are broken by this
  dontStrip = true;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
