{ stdenv
, fetchurl
, rustc
}:

let
  sources = {
    "${stdenv.lib.head stdenv.lib.platforms.x86_64-linux}" = {
      sha256 = "881d1b87acae926afd9cb7dbb9de8092143ffd1d72622829b138a195a2a5ef5b";
      platform = "x86_64-unknown-linux-gnu";
    };
  };

  version = "1.34.1";
  
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
  '';
  
  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src) urls outputHash outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprints = rustc.srcVerification.pgpKeyFingerprints;
      };
    };
    inherit version;
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
