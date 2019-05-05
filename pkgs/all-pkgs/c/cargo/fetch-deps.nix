{ stdenv
, cargo
, deterministic-zip
, fetchFromGitHub
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
    deterministic-zip'
    rustc
  ];

  CARGO_INDEX = index;

  buildCommand = ''
    cargoUnpack

    # Unpack the source with Cargo.toml
    unpackFile '${src}'

    # Fetch all of the dependencies
    pushd src >/dev/null
    cargo fetch --locked -Z no-index-update
    popd >/dev/null

    # Remove any unused data from the cargo home
    mv cargo cargo-old
    mkdir -p cargo/registry
    mv cargo-old/registry/{cache,src} cargo/registry

    SOURCE_DATE_EPOCH=946713600 deterministic-zip cargo >"$out"
  '';

  preferLocalBuild = true;

  outputHash = hash;
  outputHashMode = "flat";

  passthru = {
    inherit index;
  };
}
