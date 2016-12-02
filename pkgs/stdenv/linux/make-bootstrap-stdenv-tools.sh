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
link 'cat'
link 'chattr' || true
link 'chmod'
link 'cp'
link 'date'
link 'env'
link 'find'
link 'grep'
link 'ln'
link 'mkdir'
link 'nproc' || true
link 'sed'
link 'rm'
link 'tr'
