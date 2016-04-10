# Populate XDG_ICON_DIRS
hicolorIconThemeHook() {
  # where to find icon themes
  if [ -d "${1}/share/icons" ]; then
    addToSearchPath 'XDG_ICON_DIRS' "${1}/share"
  fi
}

envHooks+=('hicolorIconThemeHook')

# Remove icon cache
hicolorPreFixupPhase() {
  rm -fv "$out/share/icons/hicolor/icon-theme.cache"
  rm -fv "$out/share/icons/HighContrast/icon-theme.cache"
}

preFixupPhases+=('hicolorPreFixupPhase')

