# Set a fallback default value for SOURCE_DATE_EPOCH, used by some
# build tools to provide a deterministic substitute for the "current"
# time. Note that 1 = 1970-01-01 00:00:01. We don't use 0 because it
# confuses some applications.
export SOURCE_DATE_EPOCH
: ${SOURCE_DATE_EPOCH:=1}

if ! type -t determineSourceDateEpoch; then
  postUnpackHooks+=(determineSourceDateEpoch)
fi

determineSourceDateEpoch() {
  if [ -z "$srcRoot" ]; then
    return 0
  fi

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
    # timestamps properly.
    if [ "$time" -ge "$NIX_BUILD_START" ]; then
      echo "file $newestFile may be generated; SOURCE_DATE_EPOCH may be non-deterministic"
      exit 1
    fi
  fi
}
