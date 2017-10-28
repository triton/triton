default_qt_theme() {
  DEFAULT_QT_STYLE_OVERRIDE='export QT_STYLE_OVERRIDE="${QT_STYLE_OVERRIDE:-adwaita}"'
}

envHooks+=('default_qt_theme')
