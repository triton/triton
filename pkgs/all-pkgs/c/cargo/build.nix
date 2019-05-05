{ stdenv
, cargo
, git
, lib
, rustc

, rust-std
}:

{ name
, buildInputs ? [ ]
, nativeBuildInputs ? [ ]

, CARGO_DEPS
, ...
} @ args:

let
  inherit (lib)
    concatStringsSep;
in
stdenv.mkDerivation ({
  name = "rust-${rustc.version}-${name}";

  # Assume this was built from the cargo fetcher
  srcRoot = "src";

  CARGO_INDEX = CARGO_DEPS.index;

  nativeBuildInputs = nativeBuildInputs ++ [
    cargo
    git
    rustc
  ];

  buildInputs = buildInputs ++ [
    rust-std
  ];

  configurePhase = ''
    runHook 'preConfigure'

    export CARGO_HOME="$NIX_BUILD_TOP/cargo"
    export CARGO_TARGET_DIR="$NIX_BUILD_TOP/build"
    mkdir -p "$CARGO_HOME" "$CARGO_TARGET_DIR"

    runHook 'postConfigure'
  '';

  buildPhase = ''
    runHook 'preBuild'

    cargoFlagsArray+=(
      '-j' "$NIX_BUILD_CORES"
      '--frozen'
      '--release'
    )

    touch Cargo.lock
    cargo build $cargoFlags "''${cargoFlagsArray[@]}"

    runHook 'postBuild'
  '';

  installPhase = ''
    runHook 'preInstall'

    mkdir -p "$out"/bin
    find "$CARGO_TARGET_DIR"/release -mindepth 1 -maxdepth 1 -type f -executable -exec mv {} "$out"/bin \;

    runHook 'postInstall'
  '';

  disallowedReferences = [
    cargo
    git
    rustc
  ];
} // removeAttrs args [
  "name"
  "buildInputs"
  "nativeBuildInputs"
])
