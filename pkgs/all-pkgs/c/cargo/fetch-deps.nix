{ stdenv
, cargo
, cargo-vendor
, deterministic-zip
, fetchFromGitHub
, git
, rustc
}:

{ src
, zipVersion
, hash
, crates-rev
, crates-hash
}:

let
  index = fetchFromGitHub {
    version = zipVersion;
    owner = "rust-lang";
    repo = "crates.io-index";
    rev = crates-rev;
    hash = crates-hash;
  };

  deterministic-zip' = deterministic-zip.override {
    version = zipVersion;
  };
in
stdenv.mkDerivation {
  name = "cargo-deps.tar.br";

  nativeBuildInputs = [
    cargo
    cargo-vendor
    deterministic-zip'
    git
    rustc
  ];

  buildCommand = ''
    cargoUnpack

    # Pull in the registry
    CARGO_INDEX_DIR="$CARGO_HOME"/registry/index/github.com-1ecc6299db9ec823
    REGISTRY="$NIX_BUILD_TOP/registry"
    mkdir -p "$CARGO_INDEX_DIR" "$REGISTRY"
    pushd "$REGISTRY" >/dev/null
    unpackFile "${index}"
    mv * registry
    pushd registry >/dev/null
    git config --global user.name Triton
    git config --global user.email triton
    git init --separate-git-dir="$CARGO_INDEX_DIR/.git"
    git add .
    git commit -m "Initial Commit" >/dev/null
    mkdir -p "$CARGO_INDEX_DIR"/.git/refs/remotes/origin
    git rev-parse HEAD >"$CARGO_INDEX_DIR"/.git/refs/remotes/origin/master
    popd >/dev/null
    popd >/dev/null
    touch "$CARGO_INDEX_DIR"/.cargo-index-lock

    # Unpack the source with Cargo.toml
    mkdir -p src
    pushd src >/dev/null
    unpackFile '${src}'

    # Fetch all of the dependencies
    pushd * >/dev/null
    cargo fetch -Z no-index-update
    cargo vendor --frozen

    mkdir -p deps
    mv Cargo.lock vendor deps
    SOURCE_DATE_EPOCH=946713600 deterministic-zip deps >"$out"

    popd >/dev/null
    popd >/dev/null
  '';

  preferLocalBuild = true;

  outputHash = hash;
  outputHashMode = "flat";

  passthru = {
    inherit index;
  };
}
