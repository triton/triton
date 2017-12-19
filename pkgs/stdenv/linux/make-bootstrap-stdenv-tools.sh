set -e
set -o pipefail

PATH="$bootstrap/bin"
mkdir -p "$out"/bin

link() {
  local bin="$1"

  if [ ! -e "$bootstrap"/bin/"$bin" ]; then
    echo "Missing $bootstrap/bin/$bin"
    return 1
  fi

  ln -sv "$bootstrap"/bin/"$bin" "$out"/bin
}

link 'awk'
link 'basename'
link 'cat'
link 'chattr' || true
link 'chmod'
link 'cp'
link 'date'
link 'dirname'
link 'env'
link 'find'
link 'grep'
link 'head'
link 'ln'
link 'mkdir'
link 'nproc' || true
link 'readlink'
link 'rm'
link 'stat'
link 'sed'
link 'sort'
link 'tail'
link 'tr'
link 'xargs'
