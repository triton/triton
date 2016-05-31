
_tryUnrar() {
    if ! [[ "$curSrc" =~ \.rar$ ]] ; then
      return 1
    fi
    unrar x "$curSrc" > /dev/null
}

unpackCmdHooks+=('_tryUnrar')
