defaultDistAction() {
  return 0
}
if [ -z "${distAction-}" ]; then
  distAction='defaultDistAction'
fi

distPhase() {
  runHook 'preDist'

  runHook 'distAction'

  runHook 'postDist'
}
