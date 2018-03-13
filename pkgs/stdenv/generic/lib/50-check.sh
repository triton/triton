defaultCheckAction() {
  echo "We must have something to check if enabled"
  exit 1
}
if [ -z "${checkAction-}" ]; then
  checkAction='defaultCheckAction'
fi

checkPhase() {
  runHook 'preCheck'

  runHook 'checkAction'

  runHook 'postCheck'
}
