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
    (cargo.bin or cargo)
    (rustc.bin or rustc)
  ];

  buildInputs = buildInputs ++ [
    (rust-std.dev or rust-std)
  ];

  configurePhase = ''
    runHook 'preConfigure'

    if [ -n "$out" ]; then
      if [ -z "$bin" ]; then
        bin="$out"
      fi
    fi
    if [ -z "$lib" ]; then
      lib="$bin"
    fi
    if [ -n "$lib" ]; then
      export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $lib/lib"
    fi

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

  '' + (if cargo.supportsHostFlags then ''
    reldir="$CARGO_TARGET_DIR"/${target}/release
  '' else ''
    reldir="$CARGO_TARGET_DIR"/release
  '') + ''

    if [ -n "$lib" ]; then
      mkdir -p "$lib"
      find "$reldir" -mindepth 1 -maxdepth 1 -name '*'.so -exec mkdir -p "$lib"/lib \; -exec install -t "$lib"/lib {} \;
    fi
    if [ -n "$bin" ]; then
      mkdir -p "$bin"
      find "$reldir" -mindepth 1 -maxdepth 1 -executable -type f -and -not -name '*'.so -exec mkdir -p "$bin"/bin \; -exec install -t "$bin"/bin {} \;
    fi
    if [ -n "$dev" ]; then
      find "$reldir"/deps "$CARGO_TARGET_DIR"/release -mindepth 1 -maxdepth 1 -name '*'.rlib -exec mkdir -p "$dev"/lib \; -exec install -t "$dev"/lib {} \;
      if [ -n "$lib" ]; then
        mkdir -p "$dev"/nix-support
        echo "$lib" >"$dev"/nix-support/propagated-native-build-inputs
      fi
    fi

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
