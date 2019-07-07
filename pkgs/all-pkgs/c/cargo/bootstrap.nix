{ stdenv
, fetchurl
, rustc
}:

let
  sources = {
    "${stdenv.lib.head stdenv.lib.platforms.x86_64-linux}" = {
      sha256 = "9bdba485ccbe884b9ab4928e1bc107d202240c5eaf0f06e54f874ead96ffe69b";
      platform = "x86_64-unknown-linux-gnu";
    };
  };

  version = "2019-07-06";

  inherit (sources."${stdenv.targetSystem}")
    platform
    sha256;
in
stdenv.mkDerivation rec {
  name = "cargo-bootstrap-${version}";

  src = fetchurl {
    url = "https://static.rust-lang.org/dist/${version}/cargo-nightly-${platform}.tar.gz";
    hashOutput = false;
    inherit sha256;
  };

  installPhase = ''
    mkdir -p "$out"
    rm cargo/manifest.in
    rm -r cargo/share/doc
    cp -r cargo/* "$out"
    FILES=($(find $out/bin -type f))
    for file in "''${FILES[@]}"; do
      echo "Patching $file" >&2
      patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      patchelf --set-rpath "$out/lib:${stdenv.cc.cc}/lib:${stdenv.cc.libc}/lib" "$file" || true
    done

    # Check that we can launch cargo
    $out/bin/cargo --help
  '';

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
    supportsHostFlags = false;
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
