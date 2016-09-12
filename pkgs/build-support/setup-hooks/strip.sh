# This setup hook strips libraries and executables in the fixup phase.

fixupOutputHooks+=(_doStrip)

_doStrip() {
    if [ -z "$dontStrip" ]; then
        stripDebugList=${stripDebugList:-lib lib32 lib64 libexec bin sbin}
        if [ -n "$stripDebugList" ]; then
            stripDirs "$stripDebugList" "${stripDebugFlags:--S}"
        fi

        stripAllList=${stripAllList:-}
        if [ -n "$stripAllList" ]; then
            stripDirs "$stripAllList" "${stripAllFlags:--s}"
        fi
    fi
}

stripDirs() {
    local dirs="$1"
    local stripFlags="$2"
    local dirsNew=

    for d in ${dirs}; do
        if [ -d "$prefix/$d" ]; then
            dirsNew="${dirsNew} $prefix/$d "
        fi
    done
    dirs=${dirsNew}

    if [ -n "${dirs}" ]; then
        header "stripping (with flags $stripFlags) in$dirs"
        local files
        files=($(find $dirs -type f))
        for file in "${files[@]}"; do
          echo "Stripping: $file" >&2
          strip $commonStripFlags $stripFlags "$file" || true
        done
        stopNest
    fi
}
