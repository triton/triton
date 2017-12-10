addPythonPath() {
  addToSearchPathWithCustomDelimiter ':' 'PYTHONPATH' "${1}/lib/python@channel@/site-packages"
}

toPythonPath() {
  local i
  local paths
  local result

  paths="${1}"

  for i in "${paths}" ; do
    result="${result:+${result}:}${i}/lib/python@channel@/site-packages"
  done

  echo "${result}"
}

envHooks+=('addPythonPath')
