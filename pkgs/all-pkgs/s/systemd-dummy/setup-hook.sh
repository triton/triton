setupSystemdDummy() {
  local dummyPath="$TMPDIR"/systemd-dummy
  mkdir -p "$dummyPath"

  sed \
    -e 's,@PREFIX@,/run/current-system/sw,g' \
    -e "s,@INSTALL_PREFIX@,$out,g" \
    -e 's,@VERSION@,@version@,g' \
    "@udevPcIn@" >"$dummyPath"/udev.pc

  sed \
    -e 's,@PREFIX@,/run/current-system/sw,g' \
    -e "s,@INSTALL_PREFIX@,$out,g" \
    -e 's,@VERSION@,@version@,g' \
    "@systemdPcIn@" >"$dummyPath"/systemd.pc

  addToSearchPath PKG_CONFIG_PATH "$dummyPath"
}

envHook+=(setupSystemdDummy)
