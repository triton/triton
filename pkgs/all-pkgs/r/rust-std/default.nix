{ stdenv
, buildCargo
, lib
, rustc
}:

let
  target = rustc.targets."${stdenv.targetSystem}";
in
buildCargo {
  name = "std";

  inherit (rustc)
    src;

  features = [
    "backtrace"
    "panic_unwind"
  ];

  preConfigure = ''
    cd src/libstd
  '';

  preBuild = ''
    export RUSTC_BOOTSTRAP=1
  '';

  installPhase = ''
    mkdir -p "$dev" "$lib"/lib
    rm "$CARGO_TARGET_DIR"/'${target}'/release/deps/*.d
    mv "$CARGO_TARGET_DIR"/'${target}'/release/deps "$dev"/lib
    mv "$dev"/lib/*.so "$lib"/lib

    mkdir -p "$dev"/nix-support
    echo "$lib" >"$dev"/nix-support/propagated-native-build-inputs
  '';

  outputs = [
    "dev"
    "lib"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
