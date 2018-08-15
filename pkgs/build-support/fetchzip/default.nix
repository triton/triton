# This function downloads and unpacks an archive file, such as a zip
# or tar file. This is primarily useful for dynamically generated
# archives, such as GitHub's /archive URLs, where the unpacked content
# of the zip file doesn't change, but the zip file itself may
# (e.g. due to minor changes in the compression algorithm, or changes
# in timestamps).

{ lib
, deterministic-zip
, fetchurl
, unzip
}:

{ # Optionally move the contents of the unpacked tree up one level.
  stripRoot ? true
, purgeTimestamps ? false
, url ? null
, urls ? []
, extraPostFetch ? ""
, version ? null
, ... } @ args:

let
  removeTarZip = l:
    if l == [ ] then
      [ ]
    else
      let
        item = lib.head l;
        rest' = lib.tail l;
        list = if lib.any (n: item == n) [ "tar" "zip" ] then [ ] else [ item ];
        rest = if item == "tar" then lib.tail rest' else rest';
      in list ++ removeTarZip rest;

  urls' = (if url != null then [ url ] else [ ]) ++ urls;

  tarball = args.name or (baseNameOf (lib.head urls'));

  name' = args.name or (lib.concatStringsSep "." (removeTarZip (lib.splitString "." tarball)));

  deterministic-zip' = deterministic-zip.override {
    inherit version;
  };
in

lib.overrideDerivation (fetchurl (rec {
  name = "${name'}.tar.br";

  fullOpts = {
    downloadToTemp = true;

    postFetch = ''
      export PATH=${unzip}/bin:$PATH

      unpackDir="$TMPDIR/unpack"
      rm -rf "$unpackDir"
      mkdir "$unpackDir"
      cd "$unpackDir"

      mv "$downloadedFile" "$TMPDIR/tarball.${tarball}"
      unpackFile "$TMPDIR/tarball.${tarball}"

      shopt -s dotglob
      rm -rf "$TMPDIR/${name'}"
      mkdir "$TMPDIR/${name'}"
    '' + (if stripRoot then ''
      if [ $(ls "$unpackDir" | wc -l) != 1 ]; then
        echo "error: zip file must contain a single file or directory."
        exit 1
      fi
      fn=$(cd "$unpackDir" && echo *)
      if [ -f "$unpackDir/$fn" ]; then
        mv "$unpackDir/$fn" "$TMPDIR/${name'}"
      else
        mv "$unpackDir/$fn"/* "$TMPDIR/${name'}"
      fi
    '' else ''
      mv "$unpackDir"/* "$TMPDIR/${name'}"
    '') + extraPostFetch + ''
      cd "$TMPDIR"
    '' + (if purgeTimestamps then ''
      SOURCE_DATE_EPOCH="946713600"
    '' else ''
      SOURCE_DATE_EPOCH=$(find "${name'}" -type f -print0 | xargs -0 -r stat -c '%Y' | sort -n | tail -n 1)
      if [ "$NIX_BUILD_START" -lt "$SOURCE_DATE_EPOCH" ]; then
        str="The newest file is too close to the current date:\n"
        str+="  File: $(date -d "@$SOURCE_DATE_EPOCH")\n"
        str+="  Build Start: $NIX_BUILD_START\n"
        echo -e "$str" >&2
        exit 1
      fi
    '') + ''
      echo -n "Clamping to date: " >&2
      date -d "@$SOURCE_DATE_EPOCH" --utc >&2
    '' + ''
      echo "Building Archive ${name}" >&2
      ${deterministic-zip'}/bin/deterministic-zip "${name'}" >"$out"
    '';
  };
} // removeAttrs args [ "name" "version" "purgeTimestamps" "downloadToTemp" "postFetch" "stripRoot" "extraPostFetch" ]))
# Hackety-hack: we actually need unzip hooks, too
(x: {
  nativeBuildInputs = x.nativeBuildInputs ++ [
    unzip
  ];
}) // {
  inherit purgeTimestamps version;
  deterministic-zip = deterministic-zip';
}
