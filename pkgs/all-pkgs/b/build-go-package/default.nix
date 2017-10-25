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

if disabled
  then throw "${name} not supported for go ${go.meta.branch}"
else

let
  inherit (lib)
    concatMap
    concatMapStrings
    concatMapStringsSep
    concatStringsSep
    filter
    filterAttrs
    flip
    optional
    optionalAttrs
    optionalString
    ;

  args = filterAttrs (name: _: name != "extraSrcs") args';

  removeReferences = [
    go
  ];

  removeExpr = refs: flip concatMapStrings refs (ref: ''
    | sed "s,${ref},$(echo "${ref}" | sed "s,$NIX_STORE/[^-]*,$NIX_STORE/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee,"),g" \
  '');

  srcList = [
    {
      inherit goPackagePath;
      src = null;
    }
  ] ++ extraSrcs;

  srcPathsExpr = concatStringsSep "\\|" (map ({ src, goPackagePath }: goPackagePath) srcList);

  goInputs = filter (n: n ? goPackagePath) (extraSrcs ++ buildInputs ++ (args.propagatedBuildInputs or [ ]));
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
    mv "$srcRoot" "go/src/$goPackagePath"

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
        if echo "$dep" | grep -q 'example'; then
          continue
        fi

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

    if [ -z "$allowVendoredSources" ]; then
      find go/src/$goPackagePath -type d \( -name vendor -or -name Godeps \) -prune -exec rm -r {} \;
    fi
  '' + flip concatMapStrings extraSrcs ({ src, goPackagePath }: ''
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

    # Make sure we can find all of our subpackages
    missing=()
    if [ -n "$subPackages" ]; then
      for subPackage in $subPackages; do
        if [ ! -d "go/src/$goPackagePath/$subPackage" ]; then
          missing+=("$subPackage")
        fi
      done
    fi
    if [ "''${#missing[@]}" -gt "0" ]; then
      str="Missing subpackage sources:\n"
      for source in "''${missing[@]}"; do
        str+="  $source\n"
      done
      echo -en "$str" 2>&1
      exit 1
    fi

    runHook postConfigure
  '';

  renameImports = args.renameImports or (
    let
      inputsWithAliases = filter (x: x ? goPackageAliases)
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
              nextChar = substr($0, idx + 1 + length("${from}"), 1);
              if (nextChar == "\"" || nextChar == "/") {
                print substr($0, 1, idx) "${to}" substr($0, idx + 1 + length("${from}"));
              } else {
                print $0;
              }
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
      renames = p: concatMapStringsSep "\n" (rename p.goPackagePath) p.goPackageAliases;
    in ''
      pushd "go/src/$goPackagePath" >/dev/null
      ${concatMapStringsSep "\n" renames inputsWithAliases}
      popd >/dev/null
    '');

  buildPhase = args.buildPhase or ''
    runHook renameImports

    runHook preBuild

    buildFlagsArray+=(
      "-asmflags" "-trimpath '$NIX_BUILD_TOP'"
      "-gcflags" "-trimpath '$NIX_BUILD_TOP'"
    )

    export inputGoPaths="
    C
    gx
    $(find "${go}/share/go/src" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
    ${concatStringsSep "\n" (map (n: n.goPackagePath) (filter (n: (n.subPackages or null) == null) goInputs))}
    "

    export localGoPathsExact=""
    export inputGoPathsExact="
    ${concatStringsSep "\n" (concatMap (n: map (m: "${n.goPackagePath}${optionalString (m != ".") "/${m}"}") n.subPackages) (filter (n: (n.subPackages or null) != null) goInputs))}
    "

    if [ -z "$subPackages" ]; then
      export inputGoPaths="$inputGoPaths$goPackagePath"
    else
      pushd go/src >/dev/null
      export localGoPathsExact="$(echo "$subPackages" | tr ' ' '\n' | sed "s,\(^\| \|\n\),\1$goPackagePath/,g" | xargs -n 1 readlink -f | sed "s,^$(pwd)/,,")"
      popd >/dev/null
      export inputGoPathsExact="$inputGoPathsExact$localGoPathsExact"
    fi

    checkGoDir() {
      export d="$1"
      [ -n "$excludedPackages" ] && echo "$d" | grep -q "$excludedPackages" && return 0
      while read file; do
        if [ -z "$doCheck" ] && echo "$file" | grep -q '_test.go''$'; then
          continue
        fi
        if grep -q '// +build ignore' "$file"; then
          continue
        fi
        awk '
        BEGIN {
          split(ENVIRON["inputGoPaths"], inputs, "\n");
          for (i in inputs) {
            if (match(inputs[i], /^[ \t\n]*$/) == 1) {
              delete inputs[i];
            }
          }
          split(ENVIRON["inputGoPathsExact"], inputsExact, "\n");
          for (i in inputsExact) {
            if (match(inputsExact[i], /^[ \t\n]*$/) == 1) {
              delete inputsExact[i];
            }
          }
        }
        {
          if (/^[ \t]*\/\//) {
            next;
          }
          if (inStringLiteral) {
            next;
          }
          if (/^import/) {
            insideImport = 1;
            temporary = !/\($/;
          }
          if (insideImport) {
            where = match($0, /"(.*)"/, matches);
            if (where != 0) {
              isMissing = 1;
              for (i in inputs) {
                if (match(matches[1], "(^" inputs[i] "(/|$))", subMatch) == 1) {
                  isMissing = 0;
                  break;
                }
              }
              for (i in inputsExact) {
                if (match(matches[1], "(^" inputsExact[i] "$)", subMatch) == 1) {
                  isMissing = 0;
                  break;
                }
              }
              if (isMissing) {
                print matches[1] " in " ENVIRON["d"];
              }
            }
          }
          if (/^\)/) {
            insideImport = 0;
          }
          if (temporary) {
            insideImport = 0;
          }
          split($0, chars, "");
          for (i in chars) {
            c = chars[i];
            if (c == "\\" && inString && !escaped) {
              escaped = 1;
              continue;
            }
            if (c == "\"" && !escaped) {
              inString = !inString;
            }
            if (c == "`") {
              inStringLiteral = !inStringLiteral;
            };
            escaped = 0;
          }
        }
        ' "$file" >> "$TMPDIR"/missing
      done < <(find "go/src/$d" -maxdepth 1 -mindepth 1 -type f -name \*.go)
    }

  '' + (optionalString (go.channel == "1.8") ''
    ERREGEX="no buildable Go source files"
  '') + (optionalString (go.channel == "1.9") ''
    ERREGEX="\("
    ERREGEX="''${ERREGEX}build constraints exclude all Go files\|"
    ERREGEX="''${ERREGEX}no non-test Go files\|"
    ERREGEX="''${ERREGEX}no Go files\)"
  '') + ''

    buildGoDir() {
      local d; local cmd;
      cmd="$1"
      d="$2"
      if [ -n "$NIX_DEBUG" ]; then
        echo "Checking to Go Build: $dir" >&2
      fi
      [ -n "$excludedPackages" ] && echo "$d" | grep -q "$excludedPackages" && return 0
      if [ -n "$NIX_DEBUG" ]; then
        echo "Go Building: $dir" >&2
      fi
      local OUT
      if ! OUT="$(go $cmd -work''${NIX_DEBUG+ -x} -p $NIX_BUILD_CORES $buildFlags "''${buildFlagsArray[@]}" -v $d 2>&1)"; then
        if ! echo "$OUT" | grep -q "$ERREGEX"; then
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
        echo "$localGoPathsExact"
      else
        pushd go/src >/dev/null
        find "$goPackagePath" -type f -name \*$type.go -exec dirname {} \; | LC_ALL=c sort | uniq | grep -v "\(/_\|examples\|Godeps\)"
        popd >/dev/null
      fi
    }

    # Detect missing imports
    touch "$TMPDIR"/missing
    while read dir; do
      checkGoDir "$dir"
    done < <(getGoDirs "")
    missing="$(sort "$TMPDIR"/missing | uniq | awk '{print "  " $0}')"
    if [ -n "$missing" ]; then
      echo "Missing these inputs:" >&2
      echo "$missing" >&2
      exit 1
    fi

    # Build go packages
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
      subPackageExpr='\('
      for subPackage in $subPackages; do
        if [ "$subPackageExpr" != '\(' ]; then
          subPackageExpr+='\|'
        fi
        if [ "$subPackage" != "." ]; then
          subPackageExpr+="/$subPackage"
        fi
      done
      subPackageExpr+='\)'
    else
      subPackageExpr='.*'
    fi
    while read f; do
      if [ -n "$NIX_DEBUG" ]; then
        echo "Checking to Go Install: $f" >&2
      fi
      echo "$f" | grep -q '^./\(src\|pkg/[^/]*\)/\(${srcPathsExpr}\)'"$subPackageExpr"'\(/[^/]*\|\.a\)''$' || continue
      if [ -n "$NIX_DEBUG" ]; then
        echo "Go Installing: $f" >&2
      fi
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

  disallowedReferences = optional (!allowGoReference) go;

  passthru = passthru // optionalAttrs (goPackageAliases != []) { inherit goPackageAliases; };

  # I prefer to call this dev but propagatedBuildInputs expects $out to exist
  outputs = [ "out" "bin" ];

  # This breaks cgo packages like libseccomp-golang
  optimize = false;
  fortifySource = false;  # Can't fortify without optimize

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
