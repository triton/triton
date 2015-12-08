#!/usr/bin/env bash

URL="http://xorg.mirrors.pair.com/individual/"
MIRROR="mirror://xorg/individual/"

pull_tars() {
  local OUT; local DIRS; local DIR;
  OUT="$(curl -L "$1")"
  DIRS="$(echo "$OUT" | grep '\[DIR\]' | grep -v 'href="/' | sed 's,^.*href="\([^"]*\)".*,\1,g')"
  for DIR in $DIRS; do
    echo Expanding into $1$DIR >&2
    pull_tars "$1$DIR"
  done
  echo "$OUT" | grep 'tar.bz2"' | sed 's,^.*href="\([^"]*\).tar.bz2".*,\1,g' | awk "{print \$0\" $1\"\$0\".tar.bz2\"}"
}

pull_tars $URL | sort -V -r | sed "s,$URL,$MIRROR,g" | awk '{print $2}' > tarballs-7.7.list
