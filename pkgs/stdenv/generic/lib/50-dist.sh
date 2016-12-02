defaultDistAction() {
  echo "Nothing to dist"
}
if [ -z "$distAction" ]; then
  distAction='defaultDistAction'
fi

distPhase() {
  runHook 'preDist'

  runHook 'distAction'

  runHook 'postDist'
}
