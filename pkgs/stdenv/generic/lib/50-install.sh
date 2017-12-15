defaultInstallAction() {
  return 0
}
if [ -z "$installAction" ]; then
  installAction='defaultInstallAction'
fi

installPhase() {
  runHook 'preInstall'

  runHook 'installAction'

  runHook 'postInstall'
}
