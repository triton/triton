addToGoPath() {
  addToSearchPath 'GOPATH' "${1}/share/go"
}
goRpath() {
  if [ -n "$goRpathSet" ]; then
    return
  fi
  goRpathSet=1
  export GOFLAGS="$GOFLAGS -ldflags=@GO_LDFLAGS@"
}
envHooks+=('addToGoPath' 'goRpath')
