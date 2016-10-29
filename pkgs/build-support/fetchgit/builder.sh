# tested so far with:
# - no revision specified and remote has a HEAD which is used
# - revision specified and remote has a HEAD
# - revision specified and remote without HEAD
source $stdenv/setup

header "exporting $url (rev $rev) into $out"

export HEX_HASH="$(echo "$outputHash" | awk -v algo="$outputHashAlgo" \
'
function ceil(val) {
  if (val == int(val)) {
    return val;
  }
  return int(val) + 1;
}

BEGIN {
  split("0123456789abcdfghijklmnpqrsvwxyz", b32chars, "");
  for (i in b32chars) {
    b32val[b32chars[i]] = i-1;
  }
  split("0123456789abcdef", b16chars, "");
  for (i in b16chars) {
    b16val[b16chars[i]] = i-1;
  }
  if (algo == "sha256") {
    b32len = ceil(256 / 5);
    b16len = 256 / 4;
    blen = 256 / 8;
  } else if (algo == "sha512") {
    b32len = ceil(512 / 5);
    b16len = 512 / 4;
    blen = 512 / 8;
  } else {
    print "Unsupported hash algo" > "/dev/stderr";
    exit(1);
  }
}

{
  len = length($0);
  split($0, chars, "");
  if (len == b32len) {
    split("", bin);
    for (n = 0; n < len; n++) {
      c = chars[len - n];
      digit = b32val[c];
      b = n * 5;
      i = rshift(b, 3);
      j = and(b, 0x7);
      bin[i] = or(bin[i], and(lshift(digit, j), 0xff));
      bin[i+1] = or(bin[i+1], rshift(digit, 8-j));
    }
    out = "";
    for (i = 0; i < blen; i++) {
      out = out b16chars[rshift(bin[i], 4) + 1];
      out = out b16chars[and(bin[i], 0xf) + 1];
    }
    print out;
  } else if (len == b16len) {
    print $0;
  } else {
    print "Unsupported hash encoding" > "/dev/stderr";
  }
}')"

$SHELL $fetcher --builder --url "$url" --out "$out" --rev "$rev" \
  ${leaveDotGit:+--leave-dotGit} \
  ${deepClone:+--deepClone} \
  ${fetchSubmodules:+--fetch-submodules} \
  ${branchName:+--branch-name "$branchName"}

stopNest
