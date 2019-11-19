export INSTALL_SYS_DIR
: ${INSTALL_SYS_DIR:=${!defaultOutput}}

addPkgConfigPath () {
  addToSearchPath PKG_CONFIG_PATH "$1"/lib/pkgconfig
  addToSearchPath PKG_CONFIG_PATH "$1"/share/pkgconfig
}

envHooks+=(addPkgConfigPath)
