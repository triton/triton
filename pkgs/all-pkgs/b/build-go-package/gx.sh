gxConfigure() {
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
    for dep in "${deps[@]}"; do
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
}

buildFlagsArray+=(
  "-asmflags" "gx/...=-trimpath '$NIX_BUILD_TOP'"
  "-gcflags" "gx/...=-trimpath '$NIX_BUILD_TOP'"
)
preConfigureHooks+=(gxConfigure)
