{ stdenv
, fetchurl
, rustc
}:

let
  sources = {
    "${stdenv.lib.head stdenv.lib.platforms.x86_64-linux}" = {
      sha256 = "3eebd92512040baf3c0974c3ce61859646d8cf422cc515d724d857577da0dbd5";
      platform = "x86_64-unknown-linux-gnu";
    };
  };

  version = "1.17.0";
  
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
    cp -r rustc/* "$out"
    FILES=($(find $out/{bin,lib} -type f))
    for file in "''${FILES[@]}"; do
      echo "Patching $file" >&2
      patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      patchelf --set-rpath "$out/lib:${stdenv.cc.cc}/lib" "$file" || true
    done
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = rustc.srcVerification.pgpKeyFingerprints;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
