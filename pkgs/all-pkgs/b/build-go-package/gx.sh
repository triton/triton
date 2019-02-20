gxRewrite() {
  local pkg="$1"

  if [[ "$pkg" == *example* ]]; then
    return 0
  fi

  local url
  if ! url="$(jq -r '.gx.dvcsimport' "$pkg/package.json")"; then
    return 0
  fi
  if [ "$url" = "null" ]; then
    return 0
  fi

  local name="${pkg#go/src/}"
  echo "Rewriting $name"

  # Patch go files for dependencies
  ln -sr go/src "$pkg/vendor"
  pushd "$pkg" >/dev/null
  gx-go rewrite
  popd >/dev/null
  rm "$pkg/vendor"

  # Rewrite imports for self
  # We can't just symlink in case we need non-versioned imports to work
  find "$pkg" -type f -name \*.go -exec sed -i "s#\"$url\\(/\\|\"\\)#\"$name\\1#" {} \;
}
export -f gxRewrite

gxConfigure() {
  # Move all gx dependencies out of the vendor directories
  local gxdir
  for gxdir in $(find go/src -name gx -type d -depth); do
    if [[ "$gxdir" != *vendor/gx ]]; then
      continue
    fi
    cp -r "$gxdir" go/src
    rm -r "$gxdir"
  done

  # Remove all non-gx vendoring
  if [ -z "$allowVendoredSources" ]; then
    find go/src -name vendor -exec rm -r {} \; -prune
  fi

  # Find each gx package
  find go/src -name package.json -exec dirname {} \; | \
    parallel -j "$NIX_BUILD_CORES" gxRewrite
}

buildFlagsArray+=(
  "-asmflags" "gx/...=-trimpath '$NIX_BUILD_TOP'"
  "-gcflags" "gx/...=-trimpath '$NIX_BUILD_TOP'"
)
preConfigureHooks+=(gxConfigure)
