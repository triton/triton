fixupOutputHooks+=(_compressManPages)

_compressManPages() {
  [ -n "${compressManPages-1}" ] || return 0
  [ -e "$prefix"/share/man ] || return 0

  echo "Compressing man pages: $prefix" >&2
  local f
  for f in $(find "$prefix"/share/man -type f); do
    case "$(basename "$f")" in
      *.gz)
        gzip -d "$f"
        f="${f%.gz}"
        ;;
      *.bz2)
        bzip2 -d "$f"
        f="${f%.bz2}"
        ;;
      *.*.*)
        echo "Unknown compression for $f" >&2
        exit 1
        ;;
      *)
        ;;
    esac

    xz -z "$f"
  done
}
