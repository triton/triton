checkDbusDummy() {
  if pkg-config --no-uninstalled --exists dbus-1; then
    echo "dbus-dummy included with real dbus" >&2
    exit 1
  fi
}

postHooks+=(checkDbusDummy)
