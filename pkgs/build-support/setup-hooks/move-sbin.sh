# This setup hook, for each output, moves everything in $output/sbin
# to $output/bin, and replaces $output/sbin with a symlink to
# $output/bin.

fixupOutputHooks+=(_moveSbin)

_moveSbin() {
    [ -n "${moveSbin-1}" ] || return 0

    local sbin="$prefix/sbin"
    [ -e "$sbin" -a ! -L "$sbin" ] || return 0

    echo "Merging sbin into bin: $prefix"
    _mergeInto "$sbin" "$prefix"/bin
    ln -sv bin "$sbin"
}
