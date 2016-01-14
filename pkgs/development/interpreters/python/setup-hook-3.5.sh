addPythonPath() {

  addToSearchPathWithCustomDelimiter ':' 'PYTHONPATH' "${1}/lib/python3.5/site-packages"

}

toPythonPath() {

  local i
  local paths
  local result

  paths="${1}"

  for i in "${paths}" ; do
    p="${i}/lib/python3.5/site-packages"
    result="${result}${result:+:}${p}"
  done

  echo "${result}"

}

envHooks+=('addPythonPath')
