# QT plugins are version specific to the version they were built with, so we
# prefix the plugin directory to prevent including incompatible plugins.
find_qt_plugins() {
  if [ -d "$1/lib/qt-@version@/plugins" ]; then
    addToSearchPath QT_PLUGIN_PATH "$1/lib/qt-@version@/plugins"
  fi
}

envHooks+=('find_qt_plugins')
