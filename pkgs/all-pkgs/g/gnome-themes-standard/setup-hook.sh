default_gtk2_theme() {
  DEFAULT_GTK2_RC_FILES='export GTK2_RC_FILES="${GTK2_RC_FILES:-@out@/share/themes/Adwaita/gtk-2.0/gtkrc}"'
}

envHooks+=('default_gtk2_theme')
