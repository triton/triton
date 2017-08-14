# tested so far with:
# - no revision specified and remote has a HEAD which is used
# - revision specified and remote has a HEAD
# - revision specified and remote without HEAD
source $stdenv/setup

header "exporting $url (rev $rev) into $out"

str="Environment: $name\n"
str+="  HTTP_PROXY: $HTTP_PROXY\n"
str+="  HTTPS_PROXY: $HTTPS_PROXY\n"
str+="  FTP_PROXY: $FTP_PROXY\n"
str+="  ALL_PROXY: $ALL_PROXY\n"
str+="  NO_PROXY: $NO_PROXY\n"
str+="  NIX_CURL_FLAGS: $NIX_CURL_FLAGS\n"
str+="  IPFS_API: $IPFS_API\n"
echo -e "$str" 2>&1

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

tryDownload() {
  local url
  url="$1"
  local typ
  typ="$2"
  local extraOpts
  extraOpts=(
    "--continue-at" "-"
    "--fail"
  )
  local verifications
  verifications=()
  if [ -n "$insecureHashOutput" ]; then
    verifications+=('insecure')
  fi
  if echo "$url" | grep -q '^https'; then
    extraOpts+=('--ssl-reqd')
    if [ "$typ" != "main" ] || [ "$insecureProtocolDowngrade" != "1" ]; then
      extraOpts+=('--proto-redir' '-all,https')
    fi
    if [ "$typ" = "main" ] && [ "$insecureProtocolDowngrade" != "1" ] && echo "$curlOpts" | grep -q -v '\--insecure'; then
      verifications+=('https')
    fi
  fi

  echo
  header "trying $url"
  local curlexit=18;

  local success
  success=0

  # if we get error code 18, resume partial download
  while [ $curlexit -eq 18 ]; do
    # keep this inside an if statement, since on failure it doesn't abort the script
    if $curl "${extraOpts[@]}" "$url" --output "$out"; then
      if [ "$outputHashMode" = "flat" ]; then
        local lhash
        lhash="$(openssl "$outputHashAlgo" -r -hex "$out" 2>/dev/null | awk '{print $1;}')"
        if [ "$lhash" = "$HEX_HASH" ]; then
          success=1
        else
          rm -f $out
          str="Got a bad hash:\n"
          str+="  URL: $url\n"
          str+="  File: $out\n"
          if [ -n "$hashOutput" ] && [ "${#verifications[@]}" -gt 0 ]; then
            str+='  Verification:'
            local verification
            for verification in "${verifications[@]}"; do
              str+=" $verification"
            done
            str+="\n  Hash: $lhash"
          fi
          echo -e "$str" >&2
          if [ "$failEarly" = "1" ]; then
            exit 1
          fi
        fi
        break
      else
        runHook postVerification
        success=1
        break
      fi
    else
      curlexit=$?;
    fi
  done

  if [ "$success" = "1" ]; then
    if [ "$executable" = "1" ]; then
      chmod +x $out
    fi
    exit 0
  fi

  stopNest
}

fixUrls() {
  local varname
  varname="$1"

  local result
  result=()

  local array
  array="${varname}[@]"
  local url
  for url in "${!array}"; do
    if test "${url:0:9}" != "mirror://"; then
      result+=("$url")
    else
      local mirror
      mirror="$(echo "$url" | awk -F/ '{print $3}')"
      local base
      base="$(echo "$url" | awk -F/ '{ for (i=4; i<=NF; i++) { printf "%s", "/" $i; } }')"
      while read mirror; do
        eval mirror="\"$mirror\""
        result+=("$mirror$base")
      done < <(awk -v mirror="$mirror" '{
          if ($0 ~ "^" mirror " ") {
            for (i=2; i<=NF; i++) {
              print $i;
            }
          }
        }' "$mirrorsFile")
    fi
  done

  eval $varname='("${result[@]}")'

  if test -n "$showURLs"; then
    echo "${varname}:" >&2
    for url in "${!array}"; do
      echo "  $url" >&2
    done
  fi
}

export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
if ! test -f "$SSL_CERT_FILE"; then
  echo "ERROR: downloading without validating SSL cert." >&2
  echo "Please check $SSL_CERT_FILE" >&2
  exit 1
fi

# Curl flags to handle redirects, not use EPSV, handle cookies for
# servers to need them during redirects, and work on SSL without a
# certificate (this isn't a security problem because we check the
# cryptographic hash of the output anyway).
curl="curl \
 --location --max-redirs 20 \
 --retry 3 \
 --disable-epsv \
 --cookie-jar cookies \
 --speed-limit 10240 \
 --speed-time 10 \
 $curlOpts \
 $NIX_CURL_FLAGS"

# Download the actual file from ipfs before doing anything else
if [ -n "$multihash" ]; then
  if [ -n "$IPFS_API" ]; then
    tryDownload "http://$IPFS_API/ipfs/$multihash" "ipfs"
  fi
  ipfsUrls="mirror://ipfs-cached/ipfs/$multihash"
  fixUrls 'ipfsUrls'
  for iurl in "${ipfsUrls[@]}"; do
    tryDownload "$iurl" "ipfs"
  done
fi

if $SHELL $fetcher --builder --url "$url" --out "$out" --rev "$rev" \
  ${leaveDotGit:+--leave-dotGit} \
  ${deepClone:+--deepClone} \
  ${fetchSubmodules:+--fetch-submodules} \
  ${branchName:+--branch-name "$branchName"}; then
  exit 0
else
  rm -rf "$out"
fi

# We only ever want to access the official gateway as a last resort as it can be slow
if [ -n "$multihash" ]; then
  ipfsUrls="mirror://ipfs-nocache/ipfs/$multihash"
  fixUrls 'ipfsUrls'
  for iurl in "${ipfsUrls[@]}"; do
    tryDownload "$iurl" "ipfs"
  done
fi

stopNest
