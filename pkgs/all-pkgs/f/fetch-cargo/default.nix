{ stdenv
, brotli_0-4-0
, brotli_0-5-2
, brotli_0-6-0
, brotli_1-0-2
, cargo
, fetchFromGitHub
, fetchzip
, git
, gnutar_1-29
, gnutar_1-30
}:

{ package
, packageVersion

, sha256 ? null
, sha512 ? null
, outputHash ? null
, outputHashAlgo ? null
, version ? null
}:

assert version != null || throw "Missing fetchzip version. The latest version is 3.";

let
  versions = {
    "1" = {
      brotli = brotli_0-4-0;
      tar = gnutar_1-29;
    };
    "2" = {
      brotli = brotli_0-5-2;
      tar = gnutar_1-29;
    };
    "3" = {
      brotli = brotli_0-6-0;
      tar = gnutar_1-29;
    };
    "5" = {
      brotli = brotli_1-0-2;
      tar = gnutar_1-30;
    };
  };

  inherit (versions."${toString version}")
    brotli
    tar;

  index = fetchFromGitHub {
    version = 2;
    owner = "rust-lang";
    repo = "crates.io-index";
    rev = "3a2d9af68e13339cd65089c44b5bbc381f46f847";
    sha256 = "4ed12e0aaed72a399c89b9da43022ef305ef02a92f73199221c0fe65203a60d9";
  };
in
stdenv.mkDerivation {
  name = "${package}-${packageVersion}.tar.br";

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
    pushd "$CARGO_HOME/registry" >/dev/null
    unpackFile "${index}"
    pushd * >/dev/null
    git init
    git add .
    git commit -m "Initial Commit" >/dev/null
    popd >/dev/null
    popd >/dev/null

    # Configure cargo to use the local registry and predefined user settings
    sed ${./config.in} \
      -e "s,@registry@,$(echo "$CARGO_HOME/registry/"*),g" \
      -e "s,@cores@,$NIX_BUILD_CORES,g" \
      > "$CARGO_HOME/config"

    # Fetch the crate and all of its dependencies
    mkdir -p fetch-cargo
    pushd fetch-cargo >/dev/null
    cargo init
    echo '${package} = "${packageVersion}"' >> Cargo.toml
    cargo fetch
    sed -i "s,$CARGO_HOME,@CARGO_HOME@,g" Cargo.lock
    mv "$CARGO_HOME"/registry .
    popd >/dev/null

    # Remove all of the git directories for determinism
    find fetch-cargo -name .git | xargs rm -rf

    ${tar}/bin/tar --sort=name --owner=0 --group=0 --numeric-owner \
      --mode=go=rX,u+rw,a-s \
      --mtime=@946713600 \
      -c fetch-cargo | ${brotli}/bin/bro --quality 6 --output "$out"
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
