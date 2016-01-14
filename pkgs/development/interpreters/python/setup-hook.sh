addPythonPath() {

  addToSearchPathWithCustomDelimiter ':' 'PYTHONPATH' "${1}/lib/python${versionMajor}/site-packages"

}

toPythonPath() {

  local i
  local paths
  local result

  paths="${1}"

  for i in "${paths}" ; do
    p="${i}/lib/python${versionMajor}/site-packages"
    result="${result}${result:+:}${p}"
  done

  echo "${result}"

}

envHooks+=('addPythonPath')
