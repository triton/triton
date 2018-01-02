# Links all of the files in the specified directory into an output
# directory, preserving the same number of nested directory levels
deepLink() {
  local t="$1"
  local o="$2"

  local oldifs="$IFS"
  IFS="/"
  local ta=($(readlink -f "$t"))
  local oa=($(readlink -f "$o"))
  IFS="$oldifs"

  local i=${#oa[@]}
  local outdir="$o"
  while [ "$i" -lt "${#ta[@]}" ]; do
    outdir="$outdir/${ta[$i]}"
    i=$(( $i + 1 ))
  done

  mkdir -p "$outdir"
  local file
  for file in "$t"/*; do
    ln -sv $(readlink -f "$file") "$outdir"/$(basename "$file")
  done
}
