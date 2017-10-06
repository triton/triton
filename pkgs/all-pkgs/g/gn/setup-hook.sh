gnConfigurePhase() {
  eval "$preConfigure"

  echo "gn flags: $gnFlags ${gnFlagsArray[@]}"
  gn gen --args="$gnFlags ${gnFlagsArray[@]}" out/Release

  eval "$postConfigure"
}

if [ -n "${gnConfigure:-true}" -a -z "$configurePhase" ]; then
    configurePhase=gnConfigurePhase
fi
