{ go, govers, parallel, lib }:

{ name, buildInputs ? [], nativeBuildInputs ? [], passthru ? {}, preFixup ? ""

# We want parallel builds by default
, enableParallelBuilding ? true

# Disabled flag
, disabled ? false

# Go import path of the package
, goPackagePath

# Go package aliases
, goPackageAliases ? [ ]

# Extra sources to include in the gopath
, extraSrcs ? [ ]

, dontRenameImports ? false

# Do not enable this without good reason
# IE: programs coupled with the compiler
, allowGoReference ? false

, meta ? {}, ... } @ args':

if disabled then throw "${name} not supported for go ${go.meta.branch}" else

let
  args = lib.filterAttrs (name: _: name != "extraSrcs") args';

  removeReferences = [ go ];

  removeExpr = refs: lib.flip lib.concatMapStrings refs (ref: ''
    | sed "s,${ref},$(echo "${ref}" | sed "s,$NIX_STORE/[^-]*,$NIX_STORE/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee,"),g" \
  '');
in

go.stdenv.mkDerivation (
  (builtins.removeAttrs args [ "goPackageAliases" "disabled" ]) // {

  name = "go${go.meta.branch}-${name}";
  nativeBuildInputs = [ go parallel ]
    ++ (lib.optional (!dontRenameImports) govers) ++ nativeBuildInputs;
  buildInputs = [ go ] ++ buildInputs;

  configurePhase = args.configurePhase or ''
    runHook preConfigure

    # Extract the source
    cd "$NIX_BUILD_TOP"
    mkdir -p "go/src/$(dirname "$goPackagePath")"
    mv "$sourceRoot" "go/src/$goPackagePath"

    # Deal with gx dependencies
    if [ -d "go/src/$goPackagePath/vendor/gx" ]; then
      mv go/src/$goPackagePath/vendor/gx go/src
      pushd go/src
      find gx -name vendor | xargs rm -rf
      ARGS=()
      while read dep; do
        RDEP="$(awk 'BEGIN { FS="\""; } { if (/dvcsimport/) { print $4; } }' "$dep")"
        ARGS+=("-e" "s,\([^a-zA-Z/]\)$RDEP\(\"\|/\),\1$(dirname "$dep")\2,g")
      done < <(find gx -name package.json)
      find . -type f | xargs -n 1 -P $NIX_BUILD_CORES sed -i "''${ARGS[@]}"
      popd
    fi

    rm -rf go/src/$goPackagePath/vendor

  '' + lib.flip lib.concatMapStrings extraSrcs ({ src, goPackagePath }: ''
    mkdir extraSrc
    (cd extraSrc; unpackFile "${src}")
    mkdir -p "go/src/$(dirname "${goPackagePath}")"
    chmod -R u+w extraSrc/*
    mv extraSrc/* "go/src/${goPackagePath}"
    rmdir extraSrc

  '') + ''
    # Unpack all of the tarballs of other go sources
    OLDIFS="$IFS"
    IFS=":"
    NEWPATH=$NIX_BUILD_TOP/go
    mkdir -p "$NIX_BUILD_TOP/unpack"
    pushd "$NIX_BUILD_TOP/unpack"
    args=()
    decompress() {
      echo "Decompressing $1" >&2
      brotli --decompress --input "$1/files.tar.br" | tar x
    }
    export -f decompress
    for path in $GOPATH; do
      if [ -f "$path/files.tar.br" ]; then
        echo "$path"
      elif [ -d "$path/src" ]; then
        NEWPATH="$NEWPATH:$path"
      fi
    done | parallel -j "$NIX_BUILD_CORES" decompress
    EXTRAPATH="$(find $NIX_BUILD_TOP/unpack -maxdepth 1 -mindepth 1 | tr '\n' ':')"
    popd
    export GOPATH="$EXTRAPATH$NEWPATH"
    IFS="$OLDIFS"

    runHook postConfigure
  '';

  renameImports = args.renameImports or (
    let
      inputsWithAliases = lib.filter (x: x ? goPackageAliases)
        (buildInputs ++ (args.propagatedBuildInputs or [ ]));
      rename = to: from: "echo Renaming '${from}' to '${to}'; govers -d -m ${from} ${to}";
      renames = p: lib.concatMapStringsSep "\n" (rename p.goPackagePath) p.goPackageAliases;
    in lib.concatMapStringsSep "\n" renames inputsWithAliases);

  buildPhase = args.buildPhase or ''
    runHook preBuild

    runHook renameImports

    buildGoDir() {
      local d; local cmd;
      cmd="$1"
      d="$2"
      [ -n "$excludedPackages" ] && echo "$d" | grep -q "$excludedPackages" && return 0
      local OUT
      if ! OUT="$(go $cmd -p $NIX_BUILD_CORES $buildFlags "''${buildFlagsArray[@]}" -v $d 2>&1)"; then
        if ! echo "$OUT" | grep -q '\(no buildable Go source files\)'; then
          echo "$OUT" >&2
          return 1
        fi
      fi
      if [ -n "$OUT" ]; then
        echo "$OUT" >&2
      fi
      return 0
    }

    getGoDirs() {
      local type;
      type="$1"
      if [ -n "$subPackages" ]; then
        echo "$subPackages" | tr ' ' '\n' | sed "s,\(^\| \|\n\),\1$goPackagePath/,g"
      else
        pushd go/src >/dev/null
        find "$goPackagePath" -type f -name \*$type.go -exec dirname {} \; | sort | uniq | grep -v "\(/_\|examples\|Godeps\)"
        popd >/dev/null
      fi
    }

    while read dir; do
      buildGoDir install "$dir"
    done < <(getGoDirs "")

    runHook postBuild
  '';

  checkPhase = args.checkPhase or ''
    runHook preCheck

    while read dir; do
      buildGoDir test "$dir"
    done < <(getGoDirs test)

    runHook postCheck
  '';

  installPhase = args.installPhase or ''
    runHook preInstall

    mkdir -p $out
    mkdir "$NIX_BUILD_TOP/${name}"
    pushd "$NIX_BUILD_TOP/go"
    if [ -n "$subPackages" ]; then
      subPackageExpr='/\('
      for subPackage in $subPackages; do
        if [ "$subPackageExpr" != '/\(' ]; then
          subPackageExpr+='\|'
        fi
        subPackageExpr+="$subPackage"
      done
      subPackageExpr+='\)'
    fi
    while read f; do
      echo "$f" | grep -q '^./\(src\|pkg/[^/]*\)/${goPackagePath}'"$subPackageExpr" || continue
      mkdir -p "$(dirname "$NIX_BUILD_TOP/${name}/$f")"
      cp "$NIX_BUILD_TOP/go/$f" "$NIX_BUILD_TOP/${name}/$f"
    done < <(find . -type f)
    popd

    pushd "$NIX_BUILD_TOP"
    mkdir -p "$out/share/go"
    tar --sort=name --owner=0 --group=0 --numeric-owner \
      --mode=go=rX,u+rw,a-s \
      --mtime=@946713600 \
      -c "${name}" | brotli --quality 6 --output "$out/share/go/files.tar.br"
    popd

    mkdir -p $bin
    dir="$NIX_BUILD_TOP/go/bin"
    [ -e "$dir" ] && cp -r $dir $bin

    runHook postInstall
  '';

  preFixup = preFixup + ''
    while read file; do
      cat $file ${removeExpr removeReferences} > $file.tmp
      mv $file.tmp $file
      chmod +x $file
    done < <(find $bin/bin -type f 2>/dev/null)
  '';

  disallowedReferences = lib.optional (!allowGoReference) go
    ++ lib.optional (!dontRenameImports) govers;

  passthru = passthru // lib.optionalAttrs (goPackageAliases != []) { inherit goPackageAliases; };

  enableParallelBuilding = enableParallelBuilding;

  # I prefer to call this dev but propagatedBuildInputs expects $out to exist
  outputs = [ "out" "bin" ];

  meta = with lib; {
    # Add default meta information
    platforms = with platforms;
      x86_64-linux;
  } // meta // {
    # add an extra maintainer to every package
    maintainers = (meta.maintainers or [])
      ++ (with maintainers; [
        wkennington
      ]);
  };
})
