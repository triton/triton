cargoUnpack() {
  # Initial global config
  export HOME="$NIX_BUILD_TOP"
  git config --global user.email 'triton@triton.triton'
  git config --global user.name 'triton'

  # Create the home directory for cargo
  export CARGO_HOME="$NIX_BUILD_TOP/cargo"
  mkdir -p "$CARGO_HOME"

  # Setup flags for compilation
  export RUSTFLAGS="$RUSTFLAGS --remap-path-prefix $NIX_BUILD_TOP=/no-such-path"

  if [ -n "$CARGO_IGNORE_INDEX" ]; then
    return 0
  fi

  if [ -z "$CARGO_INDEX" ]; then
    echo 'ERROR: Trying to use cargo without an index' >&2
    return 1
  fi

  # Pull in the registry
  CARGO_INDEX_DIR="$CARGO_HOME"/registry/index/github.com-1ecc6299db9ec823
  REGISTRY="$NIX_BUILD_TOP/registry"
  mkdir -p "$CARGO_INDEX_DIR" "$REGISTRY"
  pushd "$REGISTRY" >/dev/null
  unpackFile "$CARGO_INDEX"
  mv * registry
  pushd registry >/dev/null
  git init --separate-git-dir="$CARGO_INDEX_DIR/.git"
  git add .
  git commit -m "Initial Commit" >/dev/null
  mkdir -p "$CARGO_INDEX_DIR"/.git/refs/remotes/origin
  git rev-parse HEAD >"$CARGO_INDEX_DIR"/.git/refs/remotes/origin/master
  popd >/dev/null
  popd >/dev/null
  touch "$CARGO_INDEX_DIR"/.cargo-index-lock

  # Unpack the deps if they are present
  if [ -n "$CARGO_DEPS" ]; then
    pushd "$NIX_BUILD_TOP" >/dev/null
    unpackFile "$CARGO_DEPS"
    popd >/dev/null
  fi
}

if [ -z "$cargoHookAdded" ]; then
  postUnpackHooks+=(cargoUnpack)
  cargoHookAdded=1
fi
