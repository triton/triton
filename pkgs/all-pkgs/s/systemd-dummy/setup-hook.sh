checkSystemdDummy() {
  if pkg-config --no-uninstalled --exists systemd || \
     pkg-config --no-uninstalled --exists udev; then
    echo "systemd-dummy included with real systemd" >&2
    exit 1
  fi
}

postHooks+=(checkSystemdDummy)
