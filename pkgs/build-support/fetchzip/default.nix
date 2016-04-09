# This function downloads and unpacks an archive file, such as a zip
# or tar file. This is primarily useful for dynamically generated
# archives, such as GitHub's /archive URLs, where the unpacked content
# of the zip file doesn't change, but the zip file itself may
# (e.g. due to minor changes in the compression algorithm, or changes
# in timestamps).

{ lib
, fetchurl
, unzip
}:

{ # Optionally move the contents of the unpacked tree up one level.
  stripRoot ? true
, purgeTimestamps ? false
, url ? null
, urls ? []
, extraPostFetch ? ""
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

  name' = args.name or (lib.concatStringsSep "." (removeTarZip (lib.splitString "." tarball)));

  urls' = (if url != null then [ url ] else [ ]) ++ urls;

  tarball = baseNameOf (lib.head urls');
in

assert urls' != [ ];

lib.overrideDerivation (fetchurl (rec {
  name = "${name'}.tar.br";

  downloadToTemp = true;

  postFetch = ''
    export PATH=${unzip}/bin:$PATH

    unpackDir="$TMPDIR/unpack"
    mkdir "$unpackDir"
    cd "$unpackDir"

    mv "$downloadedFile" "$TMPDIR/tmp.${tarball}"
    unpackFile "$TMPDIR/tmp.${tarball}"

    shopt -s dotglob
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

  '' + lib.optionalString (!purgeTimestamps) ''
    echo "Fixing mtime and atimes" >&2
    touch -t 200001010000 "${name'}"
    readarray -t files < <(find "${name'}")
    for file in "''${files[@]}"; do
      touch -h -d "@$(stat -c '%Y' "$file")" "$file"
    done
  '' + ''
    echo "Building Archive ${name}" >&2
    tar --sort=name --owner=0 --group=0 --numeric-owner \
      --mode=go=rX,u+rw,a-s \
      ${lib.optionalString purgeTimestamps "--mtime=@946713600"} \
      -c "${name'}" | brotli --quality 6 --output "$out"
    du -bhs "$out"
    cp "$out" "$TMPDIR/${name}"
  '';
} // removeAttrs args [ "name" "purgeTimestamps" "downloadToTemp" "postFetch" "stripRoot" "extraPostFetch" ]))
# Hackety-hack: we actually need unzip hooks, too
(x: {nativeBuildInputs = x.nativeBuildInputs++ [unzip];})
