{ go, parallel, lib }:

{ name, buildInputs ? [], nativeBuildInputs ? [], passthru ? {}, preFixup ? ""

# Disabled flag
, disabled ? false

# Go import path of the package
, goPackagePath

# Go package aliases
, goPackageAliases ? [ ]

# Extra sources to include in the gopath
, extraSrcs ? [ ]

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

  srcList = [
    {
      inherit goPackagePath;
      src = null;
    }
  ] ++ extraSrcs;

  srcPathsExpr = lib.concatStringsSep "\\|" (map ({ src, goPackagePath }: goPackagePath) srcList);
in

go.stdenv.mkDerivation (
  (builtins.removeAttrs args [ "goPackageAliases" "disabled" ]) // {

  name = "go${go.meta.branch}-${name}";
  nativeBuildInputs = [ go parallel ]
    ++ nativeBuildInputs;
  buildInputs = [ go ] ++ buildInputs;

  configurePhase = args.configurePhase or ''
    runHook preConfigure

    # Extract the source
    cd "$NIX_BUILD_TOP"
    mkdir -p "go/src/$(dirname "$goPackagePath")"
    mv "$sourceRoot" "go/src/$goPackagePath"

    # Deal with gx dependencies
    if [ -d "go/src/$goPackagePath/vendor/gx" ]; then
      if ! gx-go --help >/dev/null 2>&1; then
        echo "You must add gx-go.bin as a native build input." >&2
        exit 1
      fi

      mv go/src/$goPackagePath/vendor/gx go/src
      pushd go/src >/dev/null
      find gx -name vendor | xargs rm -rf
      deps=($(find gx -name package.json -exec dirname {} \;))
      for dep in "''${deps[@]}"; do
        local rdep
        rdep="$(awk -F\" '{ if (/dvcsimport/) { print $4; exit 0; } }' "$dep/package.json")"
        if [ -z "$rdep" ]; then
          continue
        fi

        # Patch go files for dependencies
        ln -sv "$(pwd)" "$dep/vendor"
        pushd "$dep" >/dev/null
        gx-go rewrite
        popd >/dev/null
        rm "$dep/vendor"

        # Patch go files for self
        find "$dep" -type f -name \*.go -print0 \
          | xargs -n 1 -0 -P $NIX_BUILD_CORES sed -i "s,\([^a-zA-Z/]\)$rdep\(\"\|/\),\1$dep\2,g"
      done
      popd >/dev/null
    fi

    find go/src/$goPackagePath -type d \( -name vendor -or -name Godeps \) -prune -exec rm -r {} \;

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
    pushd "$NIX_BUILD_TOP/unpack" >/dev/null
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
    popd >/dev/null
    IFS="$OLDIFS"

    while read dir; do
      NEWPATH="$NEWPATH:$dir"
    done < <(find "$NIX_BUILD_TOP/unpack" -maxdepth 1 -mindepth 1)
    export GOPATH="$NEWPATH"

    runHook postConfigure
  '';

  renameImports = args.renameImports or (
    let
      inputsWithAliases = lib.filter (x: x ? goPackageAliases)
        (buildInputs ++ (args.propagatedBuildInputs or [ ]));
      rename = to: from: ''
        echo Renaming '${from}' to '${to}' >&2
        find . -name \*.go -type f -print0 | xargs -0 -P "$NIX_BUILD_CORES" awk -i inplace '
        {
          if (/^import/) {
            insideImport = 1;
            temporary = !/\($/;
          }
          if (/^\)/) {
            insideImport = 0;
          }
          if (insideImport) {
            idx = index($0, "\"${from}");
            if (idx != 0) {
              print substr($0, 1, idx) "${to}" substr($0, idx + 1 + length("${from}"));
            } else {
              print $0;
            }
          } else {
            print $0;
          }
          if (temporary) {
            insideImport = 0;
          }
        }
        '
      '';
      renames = p: lib.concatMapStringsSep "\n" (rename p.goPackagePath) p.goPackageAliases;
    in ''
      pushd "go/src/$goPackagePath" >/dev/null
      ${lib.concatMapStringsSep "\n" renames inputsWithAliases}
      popd >/dev/null
    '');

  buildPhase = args.buildPhase or ''
    runHook preBuild

    runHook renameImports

    buildFlagsArray+=(
      "-asmflags" "-trimpath=$NIX_BUILD_TOP"
      "-gcflags" "-trimpath=$NIX_BUILD_TOP"
    )

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
        find "$goPackagePath" -type f -name \*$type.go -exec dirname {} \; | LC_ALL=c sort | uniq | grep -v "\(/_\|examples\|Godeps\)"
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
    pushd "$NIX_BUILD_TOP/go" >/dev/null
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
      echo "$f" | grep -q '^./\(src\|pkg/[^/]*\)/\(${srcPathsExpr}\)'"$subPackageExpr" || continue
      mkdir -p "$(dirname "$NIX_BUILD_TOP/${name}/$f")"
      cp "$NIX_BUILD_TOP/go/$f" "$NIX_BUILD_TOP/${name}/$f"
    done < <(find . -type f)
    popd >/dev/null

    pushd "$NIX_BUILD_TOP" >/dev/null
    mkdir -p "$out/share/go"
    tar --sort=name --owner=0 --group=0 --numeric-owner \
      --mode=go=rX,u+rw,a-s \
      --mtime=@946713600 \
      -c "${name}" | brotli --quality 6 --output "$out/share/go/files.tar.br"
    popd >/dev/null

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

  disallowedReferences = lib.optional (!allowGoReference) go;

  passthru = passthru // lib.optionalAttrs (goPackageAliases != []) { inherit goPackageAliases; };

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
