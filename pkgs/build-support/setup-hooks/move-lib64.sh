# This setup hook, for each output, moves everything in $output/lib64
# to $output/lib, and replaces $output/lib64 with a symlink to
# $output/lib. The rationale is that lib64 directories are unnecessary
# in Nix (since 32-bit and 64-bit builds of a package are in different
# store paths anyway).
# If the move would overwrite anything, it should fail on rmdir.

fixupOutputHooks+=(_moveLib64)

_moveLib64() {
    [ -n "${moveLib64-1}" ] || return 0

    local lib64="$prefix/lib64"
    [ -e "$lib64" -a ! -L "$lib64" ] || return 0

    echo "Merging lib64 into lib: $prefix"
    _mergeInto "$lib64" "$prefix"/lib
    ln -sv lib "$lib64"
}
