default_output() {
  for output in $outputs; do
    echo "${!output}"
    return 0
  done
}

export INSTALL_SYS_DIR
: ${INSTALL_SYS_DIR:=$(default_output)}
