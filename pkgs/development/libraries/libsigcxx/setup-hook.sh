addLibsigcxxParams() {
  if ! echo "$CXXFLAGS" | grep -q '\-std=gnu++11'; then
    export CXXFLAGS="$CXXFLAGS -std=gnu++11"
  fi
}

if [ -n "$crossConfig" ]; then
  crossEnvHooks+=(addLibsigcxxParams)
else
  envHooks+=(addLibsigcxxParams)
fi
