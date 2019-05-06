{ stdenv
, cargo
, lib
, rustc

, rust-std
}:

{ name
, buildInputs ? [ ]
, nativeBuildInputs ? [ ]
, passthru ? { }

, ...
} @ args:

let
  inherit (lib)
    concatStringsSep
    optionalString;

  target = rustc.targets."${stdenv.targetSystem}";
in
stdenv.mkDerivation ({
  name = "rust-${rustc.version}-${name}";

  nativeBuildInputs = nativeBuildInputs ++ [
    cargo
    rustc
  ];

  buildInputs = buildInputs ++ [
    rust-std
  ];

  configurePhase = ''
    runHook 'preConfigure'
    runHook 'postConfigure'
  '';

  buildPhase = ''
    runHook 'preBuild'

    cargoFlagsArray+=(
      '--frozen'
      '--release'
  '' + optionalString cargo.supportsHostFlags ''
      '--target' '${target}'
  '' + ''
    )
    if [ -n "$features" ]; then
      cargoFlagsArray+=('--features' "$features")
    fi
    if [ -n "''${buildParallel-1}" ]; then
      cargoFlagsArray+=('-j' "$NIX_BUILD_CORES")
    fi
    if [ -n "''${preferDynamic-1}" ]; then
      export RUSTFLAGS="$RUSTFLAGS -C prefer-dynamic"
    fi

    export CARGO_TARGET_DIR="$NIX_BUILD_TOP/build"
    mkdir -p "$CARGO_TARGET_DIR"
    cargo build $cargoFlags "''${cargoFlagsArray[@]}"

    runHook 'postBuild'
  '';

  installPhase = ''
    runHook 'preInstall'

    mkdir -p "$out"/bin
  '' + (if cargo.supportsHostFlags then ''
    find "$CARGO_TARGET_DIR"/${target}/release -mindepth 1 -maxdepth 1 -type f -executable -exec mv {} "$out"/bin \;
  '' else ''
    find "$CARGO_TARGET_DIR"/release -mindepth 1 -maxdepth 1 -type f -executable -exec mv {} "$out"/bin \;
  '') + ''

    runHook 'postInstall'
  '';

  passthru = passthru // {
    inherit rustc cargo target;
  };
} // removeAttrs args [
  "name"
  "buildInputs"
  "nativeBuildInputs"
])
