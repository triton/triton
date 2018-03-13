defaultInstallCheckAction() {
  echo "We must have something to install check if enabled"
  exit 1
}
if [ -z "${installCheckAction-}" ]; then
  installCheckAction='defaultInstallCheckAction'
fi

installCheckPhase() {
  runHook 'preInstallCheck'

  runHook 'installCheckAction'

  runHook 'postInstallCheck'
}
