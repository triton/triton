addToGoPath() {

  addToSearchPath 'GOPATH' "${1}/share/go"

}

envHooks+=('addToGoPath')
