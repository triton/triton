cargoEnv() {
  if [ -d "$1"/lib ] && ! [ -e "$1"/lib/.nix-ignore ]; then
    export RUSTFLAGS="$RUSTFLAGS -L$1/lib"
  fi
}

cargoUnpack() {
  # Initial global config
  export HOME="$NIX_BUILD_TOP"

  # Create the home directory for cargo
  export CARGO_HOME="$NIX_BUILD_TOP/cargo"
  mkdir -p "$CARGO_HOME"

  # Make a wrapper to consume our NIX_RUSTFLAGS
  export RUSTC_WRAPPER="$NIX_BUILD_TOP"/rustc-wrapper
  exec 10>"$RUSTC_WRAPPER"
  echo "#!$(type -tP bash)">&10
  echo 'rustc="$1"' >&10
  echo 'shift' >&10
  echo 'exec "$rustc" $NIX_RUSTFLAGS "$@"' >&10
  exec 10>&-
  chmod +x "$RUSTC_WRAPPER"

  # Remove prefix path from compiled binaries
  # We can't use the normal rustflags because cargo hashes them
  export NIX_RUSTFLAGS="$NIX_RUSTFLAGS --remap-path-prefix $NIX_BUILD_TOP=/no-such-path"

  # Unpack the deps if they are present
  if [ -n "$CARGO_DEPS" ]; then
    pushd "$NIX_BUILD_TOP" >/dev/null
    unpackFile "$CARGO_DEPS"
    popd >/dev/null
    mv "$NIX_BUILD_TOP"/deps/vendor "$srcRoot"
    if [ -f "$NIX_BUILD_TOP"/deps/Cargo.lock ]; then
      mv "$NIX_BUILD_TOP"/deps/Cargo.lock "$srcRoot"
    fi
  fi
}

cargoConfigure() {
  # Establish vendoring config if needed
  local current=$(pwd)
  while [ "$(readlink -f "$current")" != "$NIX_BUILD_TOP" ]; do
    if [ -d "$current"/vendor ]; then
      mkdir -p .cargo
      echo "[source.crates-io]" >.cargo/config
      echo "replace-with = 'vendored-sources'" >>.cargo/config
      echo "[source.vendored-sources]" >>.cargo/config
      echo "directory = '$current/vendor'" >>.cargo/config
      break;
    fi
    current="$(dirname "$current")"
  done
}

if [ -z "$cargoHookAdded" ]; then
  envHooks+=(cargoEnv)
  postUnpackHooks+=(cargoUnpack)
  preConfigureHooks+=(cargoConfigure)
  cargoHookAdded=1
fi
