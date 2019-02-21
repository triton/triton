{ stdenv
, cargo
, lib
, rustc
}:

args:

let
  inherit (lib)
    elem
    filterAttrs;

  disallowedArgs = [
    "nativeBuildInputs"
  ];
  args' = filterAttrs (n: d: !(elem n disallowedArgs)) args;
in
(stdenv.mkDerivation ({
  nativeBuildInputs = [
    cargo
    rustc
  ] ++ (args.nativeBuildInputs or [ ]);

  preUnpack = ''
    export CARGO_HOME="$TMPDIR/cargo"
    export CARGO_TARGET_DIR="$TMPDIR/build"
    mkdir -p "$CARGO_HOME" "$CARGO_TARGET_DIR"
  '';

  configurePhase = ''
    mv registry "$CARGO_HOME"
    sed -i "s,@CARGO_HOME,$CARGO_HOME,g" Cargo.lock

    # Configure cargo to use the local registry and predefined user settings
    sed ${../../f/fetch-cargo/config.in} \
      -e "s,@registry@,$(echo "$CARGO_HOME/registry/crates.io"*),g" \
      -e "s,@cores@,$NIX_BUILD_CORES,g" \
      > "$CARGO_HOME/config"
  '';

  buildPhase = ''
    runHook preBuild
    cargo build -j $NIX_BUILD_CORES --release --frozen --all-features --verbose
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cargo install -j $NIX_BUILD_CORES --root $out
    runHook postInstall
  '';
} // args')) // {
  inherit
    cargo
    rustc;
}
