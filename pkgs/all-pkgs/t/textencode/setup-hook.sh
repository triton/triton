base16len() {
  local nbytes="$1"

  echo $(( nbytes * 2 ))
}
base32len() {
  local nbytes="$1"

  echo $(( (nbytes + 4) / 5 * 5 ))
}
base64len() {
  local nbytes="$1"

  echo $(( (nbytes + 2) / 3 * 4 ))
}
nix32len() {
  local nbytes="$1"

  echo $(( (8 * nbytes + 4) / 5 ))
}
encodingType() {
  local hash="$1"
  local hashType="$2"

  declare -r -A hashByteLen=(
    [sha256]=32
    [sha512]=64
  )
  local len="${hashByteLen["$hashType"]}"
  declare -r -A encodedLenToEncoding=(
    [$(base16len "$len")]="base16"
    [$(base32len "$len")]="base32"
    [$(base64len "$len")]="base64"
    [$(nix32len "$len")]="nix32"
  )
  echo "${encodedLenToEncoding["${#hash}"]}"
}
transcodeHash() {
  local encodingType="$1"
  local hash="$2"
  shift 2

  echo "$hash" | '@out@'/bin/textencode --from="$(encodingType "$hash" "$@")" --to="$encodingType"
}
