setupSystemdDummy() {
  local dummyPath="$TMPDIR"/systemd-dummy
  mkdir -p "$dummyPath"

  sed \
    -e 's,@PREFIX@,/run/current-system/sw,g' \
    -e "s,@INSTALL_PREFIX@,$out,g" \
    -e 's,@VERSION@,1,g'\
    "@udevPcIn@" >"$dummyPath"/udev.pc

  sed \
    -e 's,@PREFIX@,/run/current-system/sw,g' \
    -e "s,@INSTALL_PREFIX@,$out,g" \
    -e 's,@VERSION@,1,g'\
    "@systemdPcIn@" >"$dummyPath"/systemd.pc

  addToSearchPath PKG_CONFIG_PATH "$dummyPath"
}

envHook+=(setupSystemdDummy)
