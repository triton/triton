# This is the builder for all X.org components.
source $stdenv/setup

installFlagsArray+=("appdefaultdir=$out/share/X11/app-defaults")

configureFlagsArray+=(
  "--disable-docs"
  "--disable-unit-tests"
)

postInstall="rm -rf $out/share/doc; $postInstall"

if test -n "$x11BuildHook"; then
  source $x11BuildHook
fi

genericBuild
