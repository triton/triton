{ stdenv
, fetchurl
, rustc
}:

let
  sources = {
    "${stdenv.lib.head stdenv.lib.platforms.x86_64-linux}" = {
      sha256 = "6c1d37c4243a6ec8622c4ff842a6113213a12f9f66875cb0f2072caaf75295a2";
      platform = "x86_64-unknown-linux-gnu";
    };
  };

  version = "1.43.1";
  
  inherit (sources."${stdenv.targetSystem}")
    platform
    sha256;
in
stdenv.mkDerivation rec {
  name = "rust-std-bootstrap-${version}";
  
  src = fetchurl {
    url = "https://static.rust-lang.org/dist/rust-std-${version}-${platform}.tar.gz";
    hashOutput = false;
    inherit sha256;
  };

  installPhase = ''
    mkdir -p "$out"
    cp -r rust-std-*/lib/rustlib/*/lib "$out"
    FILES=($(find "$out"/lib -type f))
    for file in "''${FILES[@]}"; do
      echo "Patching $file" >&2
      patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      patchelf --set-rpath "${stdenv.cc.cc}/lib:${stdenv.cc.libc}/lib" "$file" || true
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
