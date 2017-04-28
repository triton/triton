{ stdenv
, fetchurl
, makeWrapper

, rustc
, zlib
}:

let
  sources = {
    "${stdenv.lib.head stdenv.lib.platforms.x86_64-linux}" = {
      sha256 = "3601e95c968850230b137b849ff08a507e50d77ab584c779143a100f1843d8dd";
      platform = "x86_64-unknown-linux-gnu";
    };
  };

  version = "0.18.0";

  inherit (sources."${stdenv.targetSystem}")
    platform
    sha256;
in
stdenv.mkDerivation rec {
  name = "cargo-bootstrap-${version}";

  src = fetchurl {
    url = "https://static.rust-lang.org/dist/cargo-${version}-${platform}.tar.gz";
    hashOutput = false;
    inherit sha256;
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    mkdir -p "$out"
    cp -r cargo/bin "$out/bin"
    patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${stdenv.cc.cc}/lib:${zlib}/lib" $out/bin/*
    wrapProgram $out/bin/cargo --suffix PATH : "${rustc}/bin"

    # Check that we can launch cargo
    $out/bin/cargo --help
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
