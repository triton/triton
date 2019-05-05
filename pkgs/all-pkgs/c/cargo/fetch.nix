{ stdenv
, cargo
, deterministic-zip
, fetchFromGitHub
, rustc
}:

{ package
, version
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
  name = "${package}-${version}.tar.br";

  nativeBuildInputs = [
    cargo
    deterministic-zip'
    rustc
  ];

  CARGO_INDEX = index;

  buildCommand = ''
    cargoUnpack

    # Fetch the crate source itself (right now this also pulls dependencies)
    mkdir -p fetch-src
    pushd fetch-src >/dev/null
    cargo init
    echo '${package} = "${version}"' >> Cargo.toml
    cargo fetch -Z no-index-update
    popd >/dev/null

    # Pull out the crate source
    cp --no-preserve all -r $(find "$CARGO_HOME"/registry/src -name '${package}-${version}') src

    # Ensure we have a lockfile
    pushd src >/dev/null
    cargo generate-lockfile -Z no-index-update
    popd >/dev/null

    SOURCE_DATE_EPOCH=946713600 deterministic-zip src >"$out"
  '';

  preferLocalBuild = true;

  outputHash = hash;
  outputHashMode = "flat";

  passthru = {
    inherit index;
  };
}
