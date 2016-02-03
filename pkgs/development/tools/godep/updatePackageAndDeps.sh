#!/usr/bin/env bash
set -e -o pipefail

if [ "0" -eq "$#" ]; then
  echo "Takes at least one argument, the list of packages to update." >&2
  exit 1
fi

cd "$(readlink -f "$0" | xargs dirname)"
source concurrent.lib.sh

TOP_LEVEL="$(git rev-parse --show-toplevel)"
cd $TOP_LEVEL

TMPDIR=""
cleanup() {
  CODE="$?"
  echo "Cleaning up..." >&2
  if [ -n "$TMPDIR" ]; then
    rm -rf "$TMPDIR"
  fi
  exit "$?"
}
trap cleanup EXIT ERR INT QUIT PIPE TERM
TMPDIR="$(mktemp -d)"
CONCURRENT_LOG_DIR="$TMPDIR/logs"


echo "Finding packages and all dependencies..." >&2
pkglist='[ '
for arg in "$@"; do
  pkglist+="\"$arg\" "
done
pkglist+=']'

nix-build --out-link $TMPDIR/nix-list --arg pkgList "$pkglist" -E '
  { pkgList }:
  let
    pkgs = (import pkgs/top-level/all-packages.nix { });
    allBuildInputs = pkg: pkg.buildInputs
      ++ pkg.nativeBuildInputs
      ++ pkg.propagatedBuildInputs
      ++ pkg.propagatedNativeBuildInputs;
    listPkgAndDeps = pkg:
      if pkg ? goPackagePath then
        pkgs.lib.foldl
          (attr: dep: attr // listPkgAndDeps dep)
          { "${pkg.goPackagePath}" = { inherit (pkg) rev; }; }
          (allBuildInputs pkg)
      else { };
    combinedList = pkgs.lib.foldl
      (attr: n: attr // listPkgAndDeps pkgs.goPackages.${n})
      { }
      pkgList;
    pkgOutput = pkgs.lib.mapAttrsToList
      (n: d: "${n} ${d.rev}\n") combinedList;
  in
    pkgs.writeText "current-go-package-list" pkgOutput
'
cp $TMPDIR/nix-list $TMPDIR/list
rm $TMPDIR/nix-list


echo "Finding package repos..." >&2
build_redirect() {
  if echo "$1" | grep -q '\(github.com\|bitbucket.org\)'; then
    echo "$1" | sed 's,^[^h],https://\0,g'
    return 0
  fi

  local OUTPUT
  OUTPUT="$(curl "$1")"
  local IMPORT
  IMPORT="$(echo "$OUTPUT" | grep 'go-import' || true)"
  if [ -n "$IMPORT" ]; then
    echo "$IMPORT" | grep -q 'git'
    local REDIRECT
    REDIRECT="$(echo "$OUTPUT" | awk '{ if (/go-source/) { print $4 } }')"
    echo "$REDIRECT" >&2
    build_redirect "$REDIRECT"
  else
    echo "This site is unrecognized: $1" >&2
    exit 1
  fi
}
build_redirect_list() {
  local REDIRECT
  REDIRECT="$(build_redirect "$1")"
  exec 3<>"$TMPDIR/list.lock"
  flock -x 3
  sed -i "s,^[ \t]*$1 ,$1 $REDIRECT ,g" "$TMPDIR/list"
  exec 3>&-
}
ARGS=($(awk '{ print "- " $1 " build_redirect_list " $1; }' $TMPDIR/list))
concurrent "${ARGS[@]}"

echo "Fetching package revisions..." >&2

mkdir -p $TMPDIR/git
cd $TMPDIR/git
git init
awk '{ if (system("git remote add " $1 " " $2) != 0) { exit 1 } }' $TMPDIR/list

ARGS=($(awk '{ print "- " $1 " git fetch " $1; }' $TMPDIR/list))
concurrent "${ARGS[@]}"


echo "Fetching package hashes..." >&2
