{ stdenv
, cargo
, fetchFromGitHub
, git
}:

{ package
, version

, sha256 ? null
, sha512 ? null
, outputHash ? null
, outputHashAlgo ? null
}:

let
  index = fetchFromGitHub {
    owner = "rust-lang";
    repo = "crates.io-index";
    rev = "7f30ec1e170e71f88ffe2bd647a0cd16e50029d8";
    sha256 = "252da5cda7040c17921ead060689a6fd05b40ceb8d4a922caebcd83264223841";
  };
in
stdenv.mkDerivation {
  name = "${package}-${version}";

  nativeBuildInputs = [
    cargo
    git
  ];

  buildCommand = ''
    # Initial global config
    export HOME="$TMPDIR"
    git config --global user.email "triton@triton.triton"
    git config --global user.name "triton"
    export USER="triton"

    # Create the home directory for cargo
    export CARGO_HOME="$TMPDIR/cargo"
    mkdir -p "$CARGO_HOME"

    # Pull in the registry
    mkdir -p "$CARGO_HOME/registry"
    pushd "$CARGO_HOME/registry"
    unpackFile "${index}"
    pushd *
    git init
    git add .
    git commit -m "Initial Commit" >/dev/null
    popd
    popd

    # Configure cargo to use the local registry and predefined user settings
    sed ${./config.in} \
      -e "s,@registry@,$(echo "$CARGO_HOME/registry/"*),g" \
      -e "s,@cores@,$NIX_BUILD_CORES,g" \
      > "$CARGO_HOME/config"

    # Fetch the crate and all of its dependencies
    mkdir -p fetch-cargo
    pushd fetch-cargo
    cargo init
    echo '${package} = "${version}"' >> Cargo.toml
    cargo fetch
    ln -rs $(find "$CARGO_HOME/registry/src" -mindepth 2 -maxdepth 2 -type d -name "${package}-${version}") "$CARGO_HOME/src"
    popd
    rm -rf fetch-cargo

    # Create a Cargo.lock
    pushd "$CARGO_HOME/src"
    names=$(grep 'path = ".*version = "' Cargo.toml \
      | sed 's,^.*path = "\([^"]*\)".*version = "\([^"]*\)".*$,\1 \2,' \
      | awk 'print $1')
    echo "$names"
    cat "$CARGO_HOME/config"
    ls -la
    cargo generate-lockfile
    popd

    # Remove all of the git directories for determinism
    find "$CARGO_HOME" -name .git | xargs rm -rf

    touch $out
  '';

  preferLocalBuild = true;

  outputHash =
    if outputHash != null then
      outputHash
    else if sha512 != null then
      sha512
    else if sha256 != null then
      sha256
    else
      throw "Missing outputHash";

  outputHashAlgo =
    if outputHashAlgo != null then
      outputHashAlgo
    else if sha512 != null then
      "sha512"
    else if sha256 != null then
      "sha256"
    else
      throw "Missing outputHashAlgo";

  outputHashMode = "flat";
}
