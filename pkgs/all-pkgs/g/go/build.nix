{ stdenv
, go
, lib
}:

{ name
, nativeBuildInputs ? [ ]
, installedSubmodules ? null
, ...
} @ args:

let
  inherit (lib)
    concatStringsSep;

  installArg =
    if installedSubmodules != null then
      concatStringsSep " " (map (n: "./${n}") installedSubmodules)
    else
      "./...";
in
stdenv.mkDerivation ({
  name = "${go.name}-${name}";

  # Assume this was built from the module fetcher
  srcRoot = "src";

  nativeBuildInputs = nativeBuildInputs ++ [
    go
  ];

  configurePhase = ''
    runHook 'preConfigure'

    # Ensure we are using modules
    unset GOPATH
    export GO11MODULE=on

    # Go depends on a writable home directory
    export HOME="$NIX_BUILD_TOP"

    # Disallow network access
    export GOPROXY=off

    runHook 'postConfigure'
  '';

  buildPhase = ''
    runHook 'preBuild'

    # Do the actual build
    go install -trimpath -v $goFlags ${installArg}

    runHook 'postBuild'
  '';

  installPhase = ''
    runHook 'preInstall'

    mkdir -p "$out"/bin
    find "$HOME"/go/bin -type f -exec cp -v {} "$out"/bin \;

    runHook 'postInstall'
  '';

  disallowedReferences = [
    go
  ];
} // removeAttrs args [
  "name"
  "nativeBuildInputs"
  "installedSubmodules"
])
