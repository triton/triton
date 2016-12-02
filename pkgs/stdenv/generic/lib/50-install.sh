defaultInstallAction() {
  echo "Nothing to install"
}
if [ -z "$installAction" ]; then
  installAction='defaultInstallAction'
fi

installPhase() {
  runHook 'preInstall'

  runHook 'installAction'

  runHook 'postInstall'
}
