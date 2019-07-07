{ stdenv
, fetchurl
, rustc
, rust-std
}:

let
  sources = {
    "${stdenv.lib.head stdenv.lib.platforms.x86_64-linux}" = {
      sha256 = "7c149fa1695b41e8e1edcb95dca199522889f119be99f922741084d50470a9e5";
      platform = "x86_64-unknown-linux-gnu";
    };
  };

  version = "1.36.0";
  
  inherit (sources."${stdenv.targetSystem}")
    platform
    sha256;
in
stdenv.mkDerivation rec {
  name = "rustc-bootstrap-${version}";
  
  src = fetchurl {
    url = "https://static.rust-lang.org/dist/rustc-${version}-${platform}.tar.gz";
    hashOutput = false;
    inherit sha256;
  };

  installPhase = ''
    mkdir -p "$out"
    rm rustc/manifest.in
    rm rustc/bin/rust-*
    rm -r rustc/lib/rustlib/etc
    rm -r rustc/lib/rustlib/*/{bin,lib}
    rm -r rustc/share/doc
    cp -r rustc/* "$out"
    FILES=($(find $out/{bin,lib} -type f))
    for file in "''${FILES[@]}"; do
      echo "Patching $file" >&2
      patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      patchelf --set-rpath "$out/lib:${stdenv.cc.cc}/lib:${stdenv.cc.libc}/lib" "$file" || true
    done

    touch "$out"/lib/.nix-ignore

    mkdir -p "$std"
    ln -sv '${rust-std}/lib' "$std/lib"
  '';

  outputs = [
    "out"
    "std"
  ];

  setupHook = ./setup-hook.sh;
  
  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src) urls outputHash outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprints = rustc.srcVerification.pgpKeyFingerprints;
      };
    };
    inherit
      version
      platform;
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
