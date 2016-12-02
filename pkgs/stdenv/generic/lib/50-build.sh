defaultBuildAction() {
  echo "Nothing to build"
}
if [ -z "$buildAction" ]; then
  buildAction='defaultBuildAction'
fi

buildPhase() {
  runHook 'preBuild'

  runHook 'buildAction'

  runHook 'postBuild'
}
