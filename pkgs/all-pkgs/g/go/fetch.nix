{ stdenv
, deterministic-zip
, git
, go
, lib
}:

{ name
, gomod
, gosum
, sourceJSON
}:

let
  inherit (builtins.fromJSON (builtins.readFile sourceJSON))
    fetchzipVersion
    rev
    sha256;

  deterministic-zip' = deterministic-zip.override {
    version = fetchzipVersion;
  };
in
stdenv.mkDerivation {
  name = "${name}.tar.br";

  nativeBuildInputs = [
    deterministic-zip'
    git
    go
  ];

  buildCommand = ''
    # Ensure we are using modules
    unset GOPATH
    export GO11MODULE=on

    # Go depends on a writable home directory
    export HOME="$NIX_BUILD_TOP"

    # Do the initial source fetch
    mkdir src
    pushd src >/dev/null
    go mod init src 2>/dev/null
    echo "Fetching module" >&2
    gopath="$(grep '^module ' '${gomod}' | awk '{print $2}')@${rev}"
    # Ignore errors during get due to go spuriously telling us we can't build
    # This will be fine, since we check the output files
    go get -d "$gopath" || true
    popd >/dev/null
    rm -r src

    # Move the source to the expected location
    cp -r --no-preserve all go/pkg/mod/"$gopath" src

    # Remove stale data from the cache
    mv go go.old

    # Fetch the dependencies
    pushd src >/dev/null
    echo "Fetching dependencies" >&2
    cp '${gomod}' go.mod
    cp '${gosum}' go.sum
    go mod download
    popd >/dev/null

    # Remove impurities
    rm -rf go/pkg/mod/cache/vcs
    find go/pkg/mod/cache/download -name '*.zip' -delete

    # Build source tarball
    deterministic-zip go src >"$out"
  '';

  outputHashAlgo = "sha256";
  outputHashMode = "flat";
  outputHash = sha256;

  impureEnvVars = [
    # We borrow these environment variables from the caller to allow
    # easy proxy configuration.  This is impure, but a fixed-output
    # derivation like fetchurl is allowed to do so since its result is
    # by definition pure.
    "HTTP_PROXY"
    "HTTPS_PROXY"
    "FTP_PROXY"
    "ALL_PROXY"
    "NO_PROXY"
    "GIT_PROXY_COMMAND"
    "GOPROXY"
  ];

  preferLocalBuild = true;
}
