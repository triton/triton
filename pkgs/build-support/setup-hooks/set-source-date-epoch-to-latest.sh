updateSourceDateEpoch() {
    local path="$1"

    # Get the last modification time of all regular files, sort them,
    # and get the most recent. Maybe we should use
    # https://github.com/0-wiz-0/findnewest here.
    local -a res=($(find "$path" -type f -print0 | xargs -0 -r stat -c '%Y %n' | sort -n | tail -n1))
    local time="${res[0]}"
    local newestFile="${res[1]}"

    # Update $SOURCE_DATE_EPOCH if the most recent file we found is newer.
    if [ "$time" -gt "$SOURCE_DATE_EPOCH" ]; then
        echo "setting SOURCE_DATE_EPOCH to timestamp $time of file $newestFile"
        export SOURCE_DATE_EPOCH="$time"

        # Error if the new timestamp is too close to the present. This
        # may indicate that we were being applied to a file generated
        # during the build, or that an unpacker didn't restore
        # timestamps properly. Can optionally be turned into a warning.
        local now="$(date +%s)"
        local t="error"
        if [ "$sourceDateEpochWarn" = "1" ]; then
          t="warn"
        fi
        if [ "$time" -ge "$NIX_BUILD_START" ]; then
            echo "$t: file $newestFile may be generated; SOURCE_DATE_EPOCH may be non-deterministic"
            if [ "$t" = "error" ]; then
              exit 1
            fi
        fi
    fi
}

postUnpackHooks+=(_updateSourceDateEpochFromSourceRoot)

_updateSourceDateEpochFromSourceRoot() {
    if [ -n "$srcRoot" ]; then
        updateSourceDateEpoch "$srcRoot"
    fi
}
