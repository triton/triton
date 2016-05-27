{ stdenv
, cargo
}:

args:

let
  inherit (stdenv.lib)
    elem
    filterAttrs;

  disallowedArgs = [
    "nativeBuildInputs"
  ];
  args' = filterAttrs (n: d: !(elem n disallowedArgs)) args;
in
stdenv.mkDerivation ({
  nativeBuildInputs = [
    cargo
  ] ++ (args.nativeBuildInputs or [ ]);

  unpackPhase = ''
    export CARGO_HOME="$TMPDIR/cargo"
    export CARGO_TARGET_DIR="$TMPDIR/build"
    mkdir -p "$CARGO_HOME" "$CARGO_TARGET_DIR"
  '';

  configurePhase = ''
    true
  '';

  buildPhase = ''
    runHook preBuild
    cargo build -j $NIX_BUILD_CORES --release --verbose
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cargo install -j $NIX_BUILD_CORES --root $out
    runHook postInstall
  '';
} // args')
