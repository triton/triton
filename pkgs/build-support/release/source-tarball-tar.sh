#! @shell@
args=(
  "--sort=name"
  "--owner=0"
  "--group=0"
  "--numeric-owner"
)
if [[ "$1" != -* ]]; then
  args+=("-$1")
  shift
fi
for i in "$@"; do
  case "$i" in
    --sort* | --owner* | --group* | --numeric-owner)
      ;;
    *)
      args+=("$i")
      ;;
  esac
done
@tar@ "${args[@]}"
