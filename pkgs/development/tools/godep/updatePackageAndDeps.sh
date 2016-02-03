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
          { "${pkg.goPackagePath}" = {
            inherit (pkg) rev;
            date = pkg.date or "nodate";
            name = pkgs.lib.head (pkgs.lib.attrNames (pkgs.lib.filterAttrs
              (n: d: d ? goPackagePath && d.goPackagePath == pkg.goPackagePath) pkgs.goPackages));
          }; }
          (allBuildInputs pkg)
      else { };
    combinedList = pkgs.lib.foldl
      (attr: n: attr // listPkgAndDeps pkgs.goPackages.${n})
      { }
      pkgList;
    pkgOutput = pkgs.lib.mapAttrsToList
      (n: d: "${n} ${d.rev} ${d.date} ${d.name}\n") combinedList;
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

while read line; do
  pkg="$(echo "$line" | awk '{print $1}')"
  url="$(echo "$line" | awk '{print $2}')"

  mkdir -p "$TMPDIR/$pkg"
  cd "$TMPDIR/$pkg"
  git init >/dev/null
  git remote add origin "$url"

done < $TMPDIR/list

fetch_git() {
  cd $TMPDIR/$1
  git fetch --tags
}
ARGS=($(awk '{ print "- " $1 " fetch_git " $1; }' $TMPDIR/list))
concurrent "${ARGS[@]}"

while read line; do
  pkg="$(echo "$line" | awk '{print $1}')"
  rev="$(echo "$line" | awk '{print $3}')"
  date="$(echo "$line" | awk '{print $4}')"
  name="$(echo "$line" | awk '{print $5}')"

  cd $TMPDIR/$pkg

  VERSION="$(git tag | grep -v "\(dev\|alpha\|beta\|rc\)" | tail -n 1 || true)"
  HEAD_DATE="$(git log origin/master -n 1 --date=short | awk '{ if (/Date/) { print $2 } }')"
  REV="$(git rev-parse origin/master)"
  DATE="$HEAD_DATE"
  if [ -n "$VERSION" ]; then
    VERSION_DATE="$(git log "$VERSION" -n 1 --date=short | awk '{ if (/Date/) { print $2 } }')"
    # Make sure we have had a release in the past 6 months
    if [ "$(expr $(date -d "$HEAD_DATE" +'%s') - $(date -d "$VERSION_DATE" +'%s'))" -lt "15000000" ]; then
      REV="$VERSION"
      DATE="$VERSION_DATE"
    fi
  fi

  if [ "$rev" != "$REV" ]; then
    echo -e "$pkg:\n  $date $rev\n  $DATE $REV" >&2
    if [ -n "$VERSION" ]; then
      DATE="nodate"
    fi
    echo "$pkg $REV $DATE $name" >> $TMPDIR/updates
  fi
done < $TMPDIR/list

echo "Do these versions look reasonable? [y/N]"
read answer
if [ "y" != "$answer" ] && [ "yes" != "$answer" ]; then
  exit 1
fi


echo "Generating package hashes..." >&2
generate_hash() {
  pkg="$1"
  rev="$2"

  cd $TMPDIR/$pkg
  git checkout "$rev" >/dev/null 2>&1
  rm -r .git
  tar cf $TMPDIR/tmp.tar $(find . -maxdepth 1 -mindepth 1)
  HASH="$(nix-prefetch-url --unpack file://$TMPDIR/tmp.tar 2>/dev/null)"

  exec 3<>"$TMPDIR/updates.lock"
  flock -x 3
  sed -i "s, $rev , $rev $HASH ,g" "$TMPDIR/updates"
  exec 3>&-
}
ARGS=($(awk '{ print "- " $1 " generate_hash " $1 " " $2; }' $TMPDIR/updates))
concurrent "${ARGS[@]}"

export TMPDIR
awk '
BEGIN {
  updateFile=ENVIRON["TMPDIR"] "/updates";
  while((getline line < updateFile) > 0) {
    split(line, splitLine);
    exists[splitLine[5]] = 1;
    revs[splitLine[5]] = splitLine[2];
    hashes[splitLine[5]] = splitLine[3];
    dates[splitLine[5]] = splitLine[4];
  }
  close(updateFile);
  currentPkg = "";
}
{
  # Find a package opening stmt
  if (/^  [^ ]*[ ]*=/) {
    currentPkg = $1;
    shouldSetDate = dates[$1] != "nodate";
    shouldSetRev = 1;
    shouldSetHash = 1;
  }

  # Find the closing stmt and add any unadded fields
  if (/^  };/ && currentPkg != "") {
    if (shouldSetDate) {
      print "    date = \"" dates[currentPkg] "\";";
    }
    if (shouldSetRev) {
      print "    rev = \"" revs[currentPkg] "\";";
    }
    if (shouldSetHash) {
      print "    sha256 = \"" hashes[currentPkg] "\";";
    }
    currentPkg = "";
  }

  if (/^    date[ ]*=[ ]*/ && exists[currentPkg]) {
    if (shouldSetDate) {
      print "    date = \"" dates[currentPkg] "\";";
    }
    shouldSetDate = 0;
  } else if (/^    rev[ ]*=[ ]*/ && exists[currentPkg]) {
    if (shouldSetRev) {
      print "    rev = \"" revs[currentPkg] "\";";
    }
    shouldSetRev = 0;
  } else if (/^    sha256[ ]*=[ ]*/ && exists[currentPkg]) {
    if (shouldSetHash) {
      print "    sha256 = \"" hashes[currentPkg] "\";";
    }
    shouldSetHash = 0;
  } else {
    print $0;
  }
}
' $TOP_LEVEL/pkgs/top-level/go-packages.nix >$TMPDIR/go-packages.nix
mv "$TMPDIR/go-packages.nix" "$TOP_LEVEL/pkgs/top-level/go-packages.nix"
