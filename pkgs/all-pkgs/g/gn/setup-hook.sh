gnConfigurePhase() {
  eval "$preConfigure"

  echo "gn flags: $gnFlags ${gnFlagsArray[@]}"
  gn gen out/Release --args="$gnFlags ${gnFlagsArray[@]}"
  cd out/Release

  eval "$postConfigure"
}

if [ -n "${gnConfigure:-true}" -a -z "$configurePhase" ]; then
    configurePhase=gnConfigurePhase
fi
