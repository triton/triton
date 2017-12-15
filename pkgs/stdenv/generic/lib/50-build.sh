defaultBuildAction() {
  return 0
}
if [ -z "$buildAction" ]; then
  buildAction='defaultBuildAction'
fi

buildPhase() {
  runHook 'preBuild'

  runHook 'buildAction'

  runHook 'postBuild'
}
