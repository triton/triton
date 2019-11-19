appendFlags() {
  local var="$1"
  local val="$2"

  export "$var"="${!var-}${!var+ }$val"
}

maybeAppendFlagsFromFile() {
  local var="$1"
  local file="$2"

  if [ -e "$file" ]; then
    appendFlags "$var" "$(cat "$file" | tr '\n' ' ')"
  else
    export "$var"="${!var-}"
  fi
}

maybeAppendFlagsFromFile CPPFLAGS '@compiler@'/nix-support/stdincxx
maybeAppendFlagsFromFile CPPFLAGS '@compiler@'/nix-support/stdinc
maybeAppendFlagsFromFile CFLAGS '@compiler@'/nix-support/cflags
maybeAppendFlagsFromFile CFLAGS '@compiler@'/nix-support/cflags-link

maybeAppendFlagsFromFile CXXFLAGS '@compiler@'/nix-support/cxxflags
maybeAppendFlagsFromFile CXXFLAGS '@compiler@'/nix-support/cflags
maybeAppendFlagsFromFile CXXFLAGS '@compiler@'/nix-support/cxxflags-link
maybeAppendFlagsFromFile CXXFLAGS '@compiler@'/nix-support/cflags-link

maybeAppendFlagsFromFile DYLD '@compiler@'/nix-support/dynamic-linker
if [ -n "${DYLD-}" ]; then
  LDFLAGS_PRE="-dynamic-linker $DYLD"
fi
maybeAppendFlagsFromFile LDFLAGS_PRE '@compiler@'/nix-support/ldflags
maybeAppendFlagsFromFile LDFLAGS_PRE '@compiler@'/nix-support/ldflags-before
maybeAppendFlagsFromFile LDFLAGS_PRE '@compiler@'/nix-support/ldflags-dynamic

dynamicLinker=
export LDFLAGS=
for LDFLAG in $LDFLAGS_PRE; do
  if [ -n "$dynamicLinker" ]; then
    dynamicLinker=
    LDFLAGS+=" -Wl,$LDFLAG"
  elif [ "$LDFLAG" = -dynamic-linker ]; then
    dynamicLinker=1
    LDFLAGS+=" -Wl,$LDFLAG"
  else
    if [ "${LDFLAG:0:2}" = -L ]; then
      LDFLAGS+=" -Wl,-rpath -Wl,${LDFLAG:2}"
    fi
    LDFLAGS+=" $LDFLAG"
  fi
done

export CC='gcc'
export CXX='g++'

# We don't support stripping with this compiler set
doStrip=
